--[[
   A model of the complete skill graph
]]
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/skillgraph/skillmodulebinding.lua")

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
   self.stats = {
      strength = {0, 0},
      precision = {0, 0},
      wits = {0, 0},
      defense = {0, 0},
      evasion = {0, 0},
      energy = {100, 0},
      health = {100, 0},
      mobility = {1, 0},
      critChance = {0, 0},
      critBonus = {1, 0}
   }
end

SkillGraph = SkillGraph or nil

function ISLSkillGraph.initialize()
   SkillGraph = SkillGraph or ISLSkillGraph.load("/isl/skillgraph/default_skillgraph.json")
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
   ISLLog.info("Initializing Unlocked Skills")
   -- DEBUGGING
   graph:reset_unlocked_skills()
   -- END_DEBUGGING
   graph:load_unlocked_skills(status.statusProperty(SKILLS_PROPERTY_NAME) or {})
   graph:load_unlocked_skills(graph_config.initialSkills.common)
   graph:load_unlocked_skills(graph_config.initialSkills.species[player.species()] or graph_config.initialSkills.species.default)

   -- Apply save_unlocked_skills here to commit any changes afforded by
   -- updates to initialSkills.*
   graph:save_unlocked_skills()

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
   return true
end

function ISLSkillGraph:unlock_skill(skill_id, do_save, force)
   local can_unlock = force or (SkillGraph.available_skills[skill_id] and player_has_skill_point_available())

   -- Guard against repeat-unlocks
   if can_unlock and not self.unlocked_skills[skill_id] then
      ISLLog.debug("Player has unlocked '%s'", skill_id)
      self.unlocked_skills[skill_id] = true

      self:apply_skill_to_stats(skill_id)
      self:build_available_skills()
      -- TODO: Spend skill point

      if do_save then
         self:save_unlocked_skills()
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

function ISLSkillGraph:save_unlocked_skills()
   local unlocked_skills = {}
   for unlocked_skill_id, _ in pairs(self.unlocked_skills) do
      table.insert(unlocked_skills, unlocked_skill_id)
   end

   status.setStatusProperty(SKILLS_PROPERTY_NAME, unlocked_skills)

   return self;
end

function ISLSkillGraph:reset_unlocked_skills()
   status.setStatusProperty(SKILLS_PROPERTY_NAME, { "start" })
   -- TODO: Refund skill points

   return self;
end

function ISLSkillGraph:apply_skill_to_stats(skill_id)
   if not self.skills[skill_id] then return end

   for stat_name, stat_value in pairs(self.skills[skill_id].stats or {}) do
      self.stats[stat_name][1] = self.stats[stat_name][1] + stat_value
   end
end
