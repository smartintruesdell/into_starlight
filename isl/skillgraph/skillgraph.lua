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
require("/isl/skillgraph/skillmodulebinding.lua")
require("/isl/player_stats/player_stats.lua")

-- Constants ------------------------------------------------------------------

local err_msg = {}
err_msg.GRAPH_FILE_BAD_PATH = "Expected the path to a skillgraph file"
err_msg.MODULE_BINDING_BAD = "Bad module binding for '%s'"

local SKILLS_PROPERTY_NAME = "isl_unlocked_skills"

SkillGraph = SkillGraph or nil

-- Class ----------------------------------------------------------------------

ISLSkillGraph = createClass("ISLSkillGraph")

-- Constructor ----------------------------------------------------------------
function ISLSkillGraph:init()
  self.loaded_modules = {}
  self.skills = {}
  self.available_skills = {}
  self.unlocked_skills = {}
  self.stats = ISLPlayerStats.new()
end

function ISLSkillGraph.initialize()
  if not SkillGraph then
    SkillGraph = ISLSkillGraph.load("/isl/skillgraph/default_skillgraph.config")
  end

  return SkillGraph
end

function ISLSkillGraph.revert()
  SkillGraph = nil
  return ISLSkillGraph.initialize()
end

-- ISLSkillGraph.load(path) -> error, ISLSkillGraph
function ISLSkillGraph.load(path)
  local start_time = os.clock()
  local graph = nil
  assert(path ~= nil, err_msg.GRAPH_FILE_BAD_PATH)

  local graph_config = root.assetJson(path)

  -- Initialize the skill graph
  ISLLog.info("Initializing Skill Graph")
  graph = ISLSkillGraph.new()
  graph:load_modules(graph_config.skillModules.common)
  graph:load_modules(graph_config.skillModules.species[player.species()] or graph_config.skillModules.species.default)

  -- First, load any skills from the player property
  graph:load_unlocked_skills(player.getProperty(SKILLS_PROPERTY_NAME) or {})
  -- Then, load common "initialSkills" from the graph config (usually just "start")
  graph:load_unlocked_skills(graph_config.initialSkills.common)
  -- Then, load "initialSkills" for the player's species
  graph:load_unlocked_skills(graph_config.initialSkills.species[player.species()] or graph_config.initialSkills.species.default)

  -- Build available skills data
  ISLLog.info("Deriving Available Skills")
  graph:build_available_skills()

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
          self.skills[skill_id] = skill
        end
      end
    end
  end

  return self;
end

function ISLSkillGraph:load_unlocked_skills(data)
  data = data or {}

  for _, skill_id in ipairs(data) do
    self:unlock_skill(skill_id, true)
  end

  return self
end

local function player_has_skill_point_available()
  return player.isAdmin()
end

function ISLSkillGraph:unlock_skill(skill_id, force)
  -- Guard against inappropriate unlocks
  local can_unlock = force or (SkillGraph.available_skills[skill_id] and player_has_skill_point_available())

  -- Guard against repeat-unlocks
  if can_unlock and not self.unlocked_skills[skill_id] then
    ISLLog.debug("Unlocking skill '%s'", skill_id)
    self.unlocked_skills[skill_id] = true

    self:build_available_skills()
    -- TODO: Spend skill point

    self:apply_skill_to_stats(skill_id)
  end

  return self
end

function ISLSkillGraph:build_available_skills()
  -- A Skill is available for unlocking if it is adjacent to an unlocked skill
  -- and it is not unlocked.
  self.available_skills = {}

  for skill_id, skill in pairs(self.skills) do
    if self.unlocked_skills[skill_id] then
      for _, child_skill_id in ipairs(skill.children) do
        if not self.unlocked_skills[child_skill_id] then
          self.available_skills[child_skill_id] = true
        end
      end
    end
  end

  return self
end

function ISLSkillGraph:apply_to_player(player)
  assert(player ~= nil, "Tried to apply the skill graph while the player was nil")
  local unlocked_skills = {}
  for unlocked_skill_id, _ in pairs(self.unlocked_skills) do
    table.insert(unlocked_skills, unlocked_skill_id)
  end

  -- Save the player's unlocked skills as a property
  player.setProperty(SKILLS_PROPERTY_NAME, unlocked_skills)

  -- Apply derived stat updates
  ISLLog.debug(util.tableToString(self.stats))
  self.stats:apply_to_player(player)

  return self;
end

function ISLSkillGraph:reset_unlocked_skills()
  player.setProperty(SKILLS_PROPERTY_NAME, { "start" })
  -- TODO: Refund skill points

  return self:apply_to_player(player)
end

function ISLSkillGraph:apply_skill_to_stats(skill_id)
  self._get_stat_details_cache = self._get_stat_details_cache or {}
  local skill = self.skills[skill_id]
  if not skill then return end

  for stat_name, stat_value in pairs(skill.unlocks.stats or {}) do
    self._get_stat_details_cache[stat_name] = nil
    self.stats:modify_stat(stat_name, stat_value)
  end
end

function ISLSkillGraph:get_stat_details(stat_name)
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
  for skill_id, _ in pairs(self.unlocked_skills) do
    local skill_diff = self.skills[skill_id].unlocks.stats[stat_name]
    if skill_diff ~= nil then
      total_amount =
        total_amount + self.skills[skill_id].unlocks.stats[stat_name].amount

      if self.skills[skill_id].type == "species" then
        skill_diffs.from_species.amount =
          skill_diffs.from_species.amount + (skill_diff.amount or 0)
        skill_diffs.from_species.multiplier =
          skill_diffs.from_species.multiplier +
          ((skill_diff.multiplier or 1) - 1)
      elseif self.skills[skill_id].type == "perk" then
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
  end

  self._get_stat_details_cache[stat_name] = {
    from_skills = skill_diffs.from_skills.amount + (skill_diffs.from_skills.multiplier * total_amount),
    from_perks = skill_diffs.from_perks.amount + (skill_diffs.from_perks.multiplier * total_amount),
    from_species = skill_diffs.from_species.amount + (skill_diffs.from_species.multiplier * total_amount)
  }

  return self._get_stat_details_cache[stat_name]
end
