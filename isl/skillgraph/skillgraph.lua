--[[
   A model of the complete skill graph

   The way the Lua runtime executes in Starbounds prevents us from making this
   a stateful singleton so instead we want to keep it lean and let other modules
   instantiate it once per context where necessary.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/skillgraph/skillmodulebinding.lua")
require("/isl/stats/stats.lua")
require("/isl/util.lua")

-- Constants ------------------------------------------------------------------

local err_msg = {}
err_msg.GRAPH_FILE_BAD_PATH = "Expected the path to a .skillgraph file"
err_msg.MODULE_BINDING_BAD = "Bad module binding for '%s'"

local SKILLS_PROPERTY_NAME = "isl_unlocked_skills"

-- Class ----------------------------------------------------------------------

ISLSkillGraph = createClass("ISLSkillGraph")

-- Constructor ----------------------------------------------------------------
function ISLSkillGraph:init()
   self.loaded_modules = {}
   self.skills = {}
   self.available_skills = {}
   self.unlocked_skills = {}
   self.perks = {}
   self.stats = ISLStats.new()
end

SkillGraph = SkillGraph or nil

function ISLSkillGraph.initialize()
   if not SkillGraph then
      SkillGraph = ISLSkillGraph.load("/isl/skillgraph/default_skillgraph.config")
   end

   return SkillGraph
end

-- ISLSkillGraph.load(path) -> error, ISLSkillGraph
function ISLSkillGraph.load(path)
   local graph = nil
   if not path then
      return ISLLog.error(err_msg.GRAPH_FILE_BAD_PATH), nil
   end

   local graph_config = root.assetJson(path)

   -- Initialize the skill graph
   ISLLog.info("Initializing Skill Graph")
   graph = ISLSkillGraph.new()
   graph:load_modules(graph_config.skillModules.common)
   graph:load_modules(graph_config.skillModules.species[player.species()] or graph_config.skillModules.species.default)

   -- Initialize unlocked skills
   if LOG_LEVEL == LOG_LEVELS.DEBUG then
      ISLLog.debug("Resetting ISL Progression")
      graph:reset_unlocked_skills()
      graph.stats:reset_stats()
   end

   -- First, load any skills from the player property
   ISLLog.debug("Initializing Unlocked Skills - saved")
   graph:load_unlocked_skills(player.getProperty(SKILLS_PROPERTY_NAME) or {})
   -- Then, load common "initialSkills" from the graph config (usually just "start")
   ISLLog.debug("Initializing Unlocked Skills - common")
   graph:load_unlocked_skills(graph_config.initialSkills.common)
   -- Then, load "initialSkills" for the player's species
   ISLLog.debug("Initializing Unlocked Skills - %s", player.species())
   graph:load_unlocked_skills(graph_config.initialSkills.species[player.species()] or graph_config.initialSkills.species.default)

   -- Apply save_unlocked_skills here to commit stat updates and any changes
   -- afforded by updates to initialSkills.*
   graph:apply_to_player()

   -- Build available skills data
   ISLLog.info("Deriving Available Skills")
   graph:build_available_skills()

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
      self:unlock_skill(skill_id, false, true)
   end

   return self
end

local function player_has_skill_point_available()
   return player.isAdmin()
end

function ISLSkillGraph:unlock_skill(skill_id, do_save, force)
   -- Guard against inappropriate unlocks
   local can_unlock = force or (SkillGraph.available_skills[skill_id] and player_has_skill_point_available())

   -- Guard against repeat-unlocks
   if can_unlock and not self.unlocked_skills[skill_id] then
      ISLLog.debug("Player has unlocked '%s'", skill_id)
      self.unlocked_skills[skill_id] = true

      self:build_available_skills()
      self:apply_skill_to_stats(skill_id)
      -- TODO: Spend skill point

      if do_save then
         self:apply_to_player()
      end
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

function ISLSkillGraph:apply_to_player()
   local unlocked_skills = {}
   for unlocked_skill_id, _ in pairs(self.unlocked_skills) do
      table.insert(unlocked_skills, unlocked_skill_id)
   end

   -- Save the player's unlocked skills as a property
   player.setProperty(SKILLS_PROPERTY_NAME, unlocked_skills)

   -- Apply derived stat updates
   self.stats:save_to_player()

   return self;
end

function ISLSkillGraph:reset_unlocked_skills()
   player.setProperty(SKILLS_PROPERTY_NAME, { "start" })
   -- TODO: Refund skill points

   return self:apply_to_player()
end

function ISLSkillGraph:apply_skill_to_stats(skill_id)
   local skill = self.skills[skill_id]
   if not skill then return end

   for stat_name, stat_value in pairs(skill.stats or {}) do
      self.stats:modify_stat(stat_name, stat_value)
   end
end
