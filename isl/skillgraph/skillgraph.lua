--[[
  A model of the complete skill graph

  The way the Lua runtime executes in Starbounds prevents us from making this
  a stateful singleton so instead we want to keep it lean and let other modules
  instantiate it once per context where necessary.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/point.lua")
require("/isl/lib/string_set.lua")
require("/isl/skillgraph/pathfinding.lua")
require("/isl/skillgraph/skillmodulebinding.lua")
require("/isl/player_stats/player_stats.lua")

-- Constants ------------------------------------------------------------------

local err_msg = {}
err_msg.GRAPH_FILE_BAD_PATH = "Expected the path to a skillgraph file"
err_msg.MODULE_BINDING_BAD = "Bad module binding for '%s'"

local SKILLS_PROPERTY_NAME = "isl_unlocked_skills"

SkillGraph = SkillGraph or nil

-- Utility Functions ----------------------------------------------------------

local function get_saved_skills(player)
  return StringSet.new(player.getProperty(SKILLS_PROPERTY_NAME) or {})
end

local function get_skill_points(player)
  return world.entityCurrency(player.id(), "isl_skill_point")
end

local function spend_skill_points(player, amount)
  return player.consumeCurrency("isl_skill_point", amount)
end

local function refund_skill_points(player, amount)
  return player.addCurrency("isl_skill_point", amount)
end

-- Class ----------------------------------------------------------------------

ISLSkillGraph = createClass("ISLSkillGraph")

-- Constructor ----------------------------------------------------------------
function ISLSkillGraph:init()
  self.config = nil
  self.loaded_modules = {}
  self.skills = {}
  self.saved_skills = StringSet.new()
  self.available_skills = StringSet.new()
  self.unlocked_skills = StringSet.new()
  self.unlocked_perks = StringSet.new()
  self.highlight_path = {}
  self.highlight_cost = 999
  self.stats = nil
end

function ISLSkillGraph.initialize(player, force)
  assert(type(player) ~= "function", "Expected a player Object, found a function")

  if force or not SkillGraph then
    SkillGraph = ISLSkillGraph.new():load_graph(
      player,
      "/isl/skillgraph/default_skillgraph.config"
    ):load_saved_skills(player)
  end

  return SkillGraph
end

-- Methods --------------------------------------------------------------------

-- ISLSkillGraph.load_graph(player, path) -> error, ISLSkillGraph
function ISLSkillGraph:load_graph(player, path)
  local start_time = os.clock()
  assert(path ~= nil, err_msg.GRAPH_FILE_BAD_PATH)

  self.config = root.assetJson(path)

  -- Initialize the skill graph
  ISLLog.info("Initializing Skill Graph")
  self:load_modules(self.config.skillModules.common)
  self:load_modules(
    self.config.skillModules.species[player.species()] or
    self.config.skillModules.species.default
  )
  self:build_back_links()

  local elapsed_time = os.clock()-start_time
  ISLLog.debug("Loading the SkillGraph took %f seconds", elapsed_time)

  return self
end

function ISLSkillGraph:load_modules(bindings)
  bindings = bindings or {}

  for module_id, binding in pairs(bindings) do
    if not binding or not binding.path then
      ISLLog.error(err_msg.MODULE_BINDING_BAD,module_id)
    else
      binding = ISLSkillModuleBinding.new(binding)

      local skill_module = binding:load_skill_module()

      if not skill_module then
        ISLLog.error("Bad module data trying to load '%s'", module_id)
      else
        self.loaded_modules[module_id] = binding

        for skill_id, skill in pairs(skill_module:get_skills()) do
          if self.skills[skill_id] then
            ISLLog.warn(
              "Overwrote skill '%s' while loading Skill Module '%s'",
              skill_id,
              self.name
            )
          end
          skill.children = StringSet.new(skill.children)
          self.skills[skill_id] = skill
        end
      end
    end
  end

  return self;
end

function ISLSkillGraph:load_saved_skills(player)
  -- First, load any skills from the player property into our "saved skills"
  self.saved_skills = get_saved_skills(player)

  -- Then, unlock them
  self:unlock_skills(player, self.saved_skills:to_Vec(), true)

  -- Then, load common "initialSkills" from the graph config (usually just "start")
  self:unlock_skills(player, self.config.initialSkills.common, true)

  -- Then, load "initialSkills" for the player's species (usually none)
  self:unlock_skills(
    player,
    self.config.initialSkills.species[player.species()] or
    self.config.initialSkills.species.default,
    true
  )

  -- Build available skills data
  self:build_available_skills()

  -- Save the current graph back to the player (and trigger an update)
  self:write_skills_to_player(player)

  return self
end

function ISLSkillGraph:unlock_skill(_player, skill_id)
  ISLLog.debug("Unlocking skill '%s'", skill_id)

  self.unlocked_skills:add(skill_id)

  if (self.skills[skill_id].type == "perk") then
    self.unlocked_perks:add(skill_id)
  end

  return self
end

function ISLSkillGraph:unlock_skills(player, skill_id_list)
  for _, skill_id in ipairs(skill_id_list or {}) do
    if not self.unlocked_skills:contains(skill_id) then
      self:unlock_skill(player, skill_id)
    end
  end

  return self
end



function ISLSkillGraph:build_back_links()
  -- For each skill,
  for skill_id, skill in pairs(self.skills) do
    -- Add that skill's id to the children of each of its children
    for _, child_id in ipairs(skill.children:to_Vec()) do
      assert(
        self.skills[child_id] ~= nil,
        "Tried to link to "..child_id..", which was not a known skill"
      )
      self.skills[child_id].children:add(skill_id)
    end
  end

  return self
end

function ISLSkillGraph:build_available_skills()
  ISLLog.info("Deriving Available Skills")
  -- A Skill is available for unlocking if it is adjacent to an unlocked skill
  -- and it is not unlocked.
  self.available_skills = StringSet.new()

  -- For each skill,
  for skill_id, skill in pairs(self.skills) do
    -- If that skill is unlocked,
    if self.unlocked_skills:contains(skill_id) then
      -- Add all of its children to the list of available skills
      self.available_skills:add_many(skill.children:to_Vec())
    end
  end

  -- Then remove all of the unlocked skills from the list
  self.available_skills:remove_many(self.unlocked_skills:to_Vec())

  return self
end


function ISLSkillGraph:write_skills_to_player(player)
  assert(player ~= nil, "Tried to apply the skill graph while the player was nil")

  -- Save the player's unlocked skills as a property
  self.saved_skills = self.unlocked_skills:clone()
  player.setProperty(SKILLS_PROPERTY_NAME, self.saved_skills:to_Vec())

  -- Inform the player that their stats have changed
  world.sendEntityMessage(player.id(), "isl_skillgraph_updated")

  return self;
end


function ISLSkillGraph:apply_status_effects_to_player(_--[[Player]])
  for skill_id, _ in pairs(self.saved_skills) do
    if self.skills[skill_id].effectName then
      -- ISLLog.debug(
      --   "Applying skill effect `%s` to player",
      --   self.skills[skill_id].effectName
      -- )
      status.addEphemeralEffect(self.skills[skill_id].effectName, math.huge)
    end
  end
end

function ISLSkillGraph:remove_status_effects_from_player(_--[[Player]])
  for skill_id, _ in pairs(self.saved_skills) do
    if self.skills[skill_id].effectName then
      status.removeEphemeralEffect(self.skills[skill_id].effectName)
    end
  end
end

-- UI Methods -----------------------------------------------------------------

function ISLSkillGraph:user_unlock_skill(player, skill_id)
  local skill_is_affordable =
    player.isAdmin() or get_skill_points(player) > 0

  if skill_is_affordable then
    spend_skill_points(player, 1)
    self:unlock_skill(player, skill_id)
    self:build_available_skills()
  end

  return self
end


function ISLSkillGraph:user_unlock_skills(player, skill_ids)
  local skills_are_affordable =
    player.isAdmin() or get_skill_points(player) >= #skill_ids

  if skills_are_affordable then
    spend_skill_points(player, #skill_ids)
    self:unlock_skills(player, skill_ids)
    self:build_available_skills()
  end

  return self
end


function ISLSkillGraph:user_lock_skill(player, skill_id)
  local function all_unlocked_children_are_supported()
    -- For each of the children of the specified node,
    for child_id, _ in pairs(self.skills[skill_id].children) do
      -- If that child is unlocked, we want to make sure it has
      -- a valid path back to `start` even if our node were locked.
      if child_id ~= "start" and self.unlocked_skills:contains(child_id) then
        local path = find_shortest_path(
          self,
          "start",
          child_id,
          false,
          StringSet.new({ skill_id })
        )

        if not path then return false end
      end
    end
    return true
  end

  local skill_is_lockable =
    self.skills[skill_id].type ~= "species" and
    self.unlocked_skills:contains(skill_id) and
    all_unlocked_children_are_supported()

  if skill_is_lockable then
    ISLLog.debug("Locking skill '%s'", skill_id)
    self.unlocked_skills:remove(skill_id)
    self.unlocked_perks:remove(skill_id)
    refund_skill_points(player, 1)

    self:build_available_skills()
  end

  return self
end

-- This is the user-facing version of unlock skill
function ISLSkillGraph:user_toggle_skill_if_possible(player, skill_id)
  if self.unlocked_skills:contains(skill_id) then
    self:user_lock_skill(player, skill_id)

    return true
  elseif self.available_skills:contains(skill_id) then
    self:user_unlock_skill(player, skill_id)

    return true
  end

  return false
end


function ISLSkillGraph:highlight_path_to_skill(goal_id)
  local path, cost = find_shortest_path(
    self,
    "start",
    goal_id,
    true
  )
  self.highlight_path = path
  self.highlight_cost = cost

  return self
end


function ISLSkillGraph:clear_highlight_path()
  self.highlight_path = nil
  self.highlight_cost = 999
end


function ISLSkillGraph:unlock_highlighted_skills(player)
  return self:user_unlock_skills(player, self.highlight_path)
end


function ISLSkillGraph:revert(player)
  refund_skill_points(player, self.unlocked_skills:size() - self.saved_skills:size())

  return ISLSkillGraph.initialize(player, true)
end


function ISLSkillGraph.reset_unlocked_skills(player)
  local prev_skills = player.getProperty(SKILLS_PROPERTY_NAME, {})

  player.addCurrency("isl_skill_point", #prev_skills - 1) -- -1 for 'start'
  player.setProperty(SKILLS_PROPERTY_NAME, {})

  return ISLSkillGraph.initialize(player, true)
end


-- DEAD CODE ------------------------------------------------------------------

--TODO: Dead code, maybe repurpose?
function ISLSkillGraph:apply_skill_to_stats(skill_id)
  local skill = self.skills[skill_id]
  if skill then
    for stat_name, stat_value in pairs(skill.unlocks.stats or {}) do
      self._get_stat_details_cache[stat_name] = nil
      self.stats:modify_stat(stat_name, stat_value)
    end
  end

  return self
end


--TODO: Dead code, maybe repurpose?
function ISLSkillGraph:apply_skills_to_stats(player)
  self.stats = ISLPlayerStats.new(player.id())
  for _, skill_id in ipairs(self.unlocked_skills:to_Vec()) do
    self:apply_skill_to_stats(skill_id)
  end

  return self
end


--TODO: Deprecate
function ISLSkillGraph:get_stat_details()
  return {
    from_skills = 0,
    from_perks = 0,
    from_species = 0
  }
end
