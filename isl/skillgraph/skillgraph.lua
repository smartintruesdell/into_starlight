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

-- Class ----------------------------------------------------------------------

ISLSkillGraph = createClass("ISLSkillGraph")

-- Constructor ----------------------------------------------------------------
function ISLSkillGraph:init()
   self.loaded_modules = {}
   self.skills = {}
   self.available_skills = {}
   self.unlocked_skills = {}
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
   graph:load_unlocked_skills(status.statusProperty("isl_unlocked_skills") or {})
   graph:load_unlocked_skills(graph_config.initialSkills.common)
   graph:load_unlocked_skills(graph_config.initialSkills.species[player.species()] or graph_config.initialSkills.species.default)

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
      self:unlock_skill(skill_id)
   end

   return self
end

function ISLSkillGraph:unlock_skill(skill_id)
   ISLLog.debug("Player has unlocked '%s'", skill_id)
   self.unlocked_skills[skill_id] = true

   return self
end

function ISLSkillGraph:build_available_skills()
   self.available_skills = {}

   return self
end
