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
  return player.getProperty(SKILLS_PROPERTY_NAME) or {}
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
  self.loaded_modules = {}
  self.skills = {}
  self.saved_skills = StringSet.new()
  self.available_skills = StringSet.new()
  self.unlocked_skills = StringSet.new()
  self.unlocked_perks = StringSet.new()
  self.highlight_path = {}
  self.highlight_cost = 999
  self.stats = ISLPlayerStats.new()
end

function ISLSkillGraph.initialize(player)
  if not SkillGraph then
    SkillGraph = ISLSkillGraph.load(
      player,
      "/isl/skillgraph/default_skillgraph.config"
    )
  end

  return SkillGraph
end

function ISLSkillGraph:revert(player)
  refund_skill_points(player, self.unlocked_skills:size() - self.saved_skills:size())

  SkillGraph = nil
  return ISLSkillGraph.initialize(player)
end

-- ISLSkillGraph.load(path) -> error, ISLSkillGraph
function ISLSkillGraph.load(player, path)
  local start_time = os.clock()
  local graph = nil
  assert(path ~= nil, err_msg.GRAPH_FILE_BAD_PATH)

  local graph_config = root.assetJson(path)

  -- Initialize the skill graph
  ISLLog.info("Initializing Skill Graph")
  graph = ISLSkillGraph.new()
  graph:load_modules(graph_config.skillModules.common)
  graph:load_modules(
    graph_config.skillModules.species[player.species()] or
    graph_config.skillModules.species.default
  )
  graph:build_back_links()

  -- First, load any skills from the player property into our "saved skills"
  graph.saved_skills:add_many(get_saved_skills(player))

  -- Then, unlock them
  graph:unlock_skills(player, graph.saved_skills:to_Vec(), true)

  -- Then, load common "initialSkills" from the graph config (usually just "start")
  graph:unlock_skills(player, graph_config.initialSkills.common, true)

  -- Then, load "initialSkills" for the player's species (usually none)
  graph:unlock_skills(
    player,
    graph_config.initialSkills.species[player.species()] or
    graph_config.initialSkills.species.default,
    true
  )

  -- Build available skills data
  graph:build_available_skills()

  -- And update our stats object
  graph:apply_skills_to_stats()

  ISLLog.debug(
    "Loading the SkillGraph took %f seconds",
    os.clock()-start_time
  )

  return graph
end

-- Methods --------------------------------------------------------------------

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

function ISLSkillGraph:unlock_skills(player, skill_id_list, force)
  for _, skill_id in ipairs(skill_id_list or {}) do
    if not self.unlocked_skills:contains(skill_id) then
      self:unlock_skill(player, skill_id, force)
    end
  end
  if not force then
    self:build_available_skills()
    self:apply_skills_to_stats()
  end

  return self
end

function ISLSkillGraph:unlock_skill(player, skill_id, force)
  local skill_is_affordable =
    force or player.isAdmin() or get_skill_points(player) > 0

  if skill_is_affordable then
    ISLLog.debug("Unlocking skill '%s'", skill_id)
    self.unlocked_skills:add(skill_id)
    if (self.skills[skill_id].type == "perk") then
      self.unlocked_perks:add(skill_id)
    end
    if not force then
      spend_skill_points(player, 1)
    end
  else
    ISLLog.debug("skill was unaffordable")
  end

  if not force then
    -- Force is used during initialization, but afterwards any
    -- unlocks should be accompanied by a rebuild of relationships
    self:build_available_skills()
    self:apply_skills_to_stats()
  end

  return self
end

function ISLSkillGraph:unlock_highlighted_skills(player)
  for _, skill_id in ipairs(self.highlight_path or {}) do
    self:unlock_skill(player, skill_id)
  end

  return self
end

function ISLSkillGraph:lock_skill(player, skill_id)
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
  end

  self:build_available_skills()
  self:apply_skills_to_stats()

  return self
end

-- This is the user-facing version of unlock skill
function ISLSkillGraph:toggle_skill_if_possible(player, skill_id)
  if self.unlocked_skills:contains(skill_id) then
    self:lock_skill(player, skill_id)
    return true
  elseif self.available_skills:contains(skill_id) then
    self:unlock_skill(player, skill_id)
    return true
  end
  return false
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

function ISLSkillGraph:apply_to_player(player)
  assert(player ~= nil, "Tried to apply the skill graph while the player was nil")

  -- Save the player's unlocked skills as a property
  self.saved_skills = self.unlocked_skills:clone()
  player.setProperty(SKILLS_PROPERTY_NAME, self.saved_skills:to_Vec())


  -- Apply derived stat updates
  self:apply_perks_to_player(player)
  world.sendEntityMessage(player.id(), "isl_skillgraph_updated")

  return self;
end

function ISLSkillGraph.reset_unlocked_skills(player)
  local prev_skills = player.getProperty(SKILLS_PROPERTY_NAME, {})

  player.addCurrency("isl_skill_point", #prev_skills - 1) -- -1 for 'start'
  player.setProperty(SKILLS_PROPERTY_NAME, {})

  SkillGraph = nil
  return ISLSkillGraph.initialize(player.id)
end

function ISLSkillGraph:apply_skill_to_stats(skill_id)
  self._get_stat_details_cache = self._get_stat_details_cache or {}
  local skill = self.skills[skill_id]
  if not skill then return end

  for stat_name, stat_value in pairs(skill.unlocks.stats or {}) do
    self._get_stat_details_cache[stat_name] = nil
    self.stats:modify_stat(stat_name, stat_value)
  end

  return self
end

function ISLSkillGraph:apply_skills_to_stats()
  self.stats = ISLPlayerStats.new()
  for _, skill_id in ipairs(self.unlocked_skills:to_Vec()) do
    self:apply_skill_to_stats(skill_id)
  end

  return self
end

--TODO: I think I need to rework this in a "now I use stock stats world"
function ISLSkillGraph:get_stat_details(stat_name)
  assert(stat_name ~= nil, "Tried to retrieve stat details for `nil`")

  self._get_stat_details_cache = self._get_stat_details_cache or {}
  if self._get_stat_details_cache[stat_name] then
    return self._get_stat_details_cache[stat_name]
  end

  local total_amount = 0
  local skill_diffs = {
    from_skills = {
      amount = 0,
      multiplier = 0
    },
    from_perks = {
      amount = 0,
      multiplier = 0
    },
    from_species = {
      amount = 0,
      multiplier = 0
    }
  }
  for _, skill_id in ipairs(self.unlocked_skills:to_Vec()) do
    assert(self.skills ~= nil, "Skills was not initialized")
    assert(self.skills[skill_id] ~= nil, "Had an unlocked skill that was not available")
    local skill = self.skills[skill_id]
    assert(skill.unlocks ~= nil, "Bad skill data")
    if not skill.unlocks.stats then goto continue end

    local skill_diff = skill.unlocks.stats[stat_name]

    if skill_diff ~= nil then
      total_amount =
        total_amount + (skill.unlocks.stats[stat_name].amount or 0)

      if skill.type == "species" then
        skill_diffs.from_species.amount =
          skill_diffs.from_species.amount + (skill_diff.amount or 0)
        skill_diffs.from_species.multiplier =
          skill_diffs.from_species.multiplier +
          ((skill_diff.multiplier or 1) - 1)
      elseif skill.type == "perk" then
        skill_diffs.from_perks.amount =
          skill_diffs.from_perks.amount + (skill_diff.amount or 0)
        skill_diffs.from_perks.multiplier =
          skill_diffs.from_perks.multiplier +
          ((skill_diff.multiplier or 1) - 1)
      else
        skill_diffs.from_skills.amount =
          skill_diffs.from_skills.amount + (skill_diff.amount or 0)
        skill_diffs.from_skills.multiplier =
          skill_diffs.from_skills.multiplier +
          ((skill_diff.multiplier or 1) - 1)
      end
    end
    ::continue::
  end

  self._get_stat_details_cache[stat_name] = {
    from_skills = skill_diffs.from_skills.amount + (skill_diffs.from_skills.multiplier * total_amount),
    from_perks = skill_diffs.from_perks.amount + (skill_diffs.from_perks.multiplier * total_amount),
    from_species = skill_diffs.from_species.amount + (skill_diffs.from_species.multiplier * total_amount)
  }

  return self._get_stat_details_cache[stat_name]
end


function ISLSkillGraph:apply_perks_to_player(player)
  ISLLog.debug("Applying perks to player")
  for skill_id, _ in pairs(self.saved_skills) do
    if self.skills[skill_id].type == "perk" then
      local effect_id = self.skills[skill_id].effectName

      if not effect_id then
        ISLLog.warn("Perk %s did not have an associated effect", skill_id)
        goto continue
      end

      status.addEphemeralEffect(effect_id, math.huge)
    end
    ::continue::
  end
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

return ISLSkillGraph
