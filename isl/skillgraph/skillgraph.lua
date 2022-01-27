--[[
   A model of the complete skill graph
]]
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/skillmodule/skillmodulebinding.lua")

-- Constants ------------------------------------------------------------------

local err_msg = {}
err_msg.GRAPH_FILE_BAD_PATH = "Expected the path to a .skillgraph file"
err_msg.GRAPH_FILE_NOT_FOUND = ".skillgraph not found at '%s'"
err_msg.MODULE_BINDING_BAD = "Bad module binding for '%s'"

-- Class ----------------------------------------------------------------------

ISLSkillGraph = createClass("ISLSkillGraph")

-- Constructor ----------------------------------------------------------------
function ISLSkillGraph:init(data)
   self.loaded_modules = {}
   self.skills = {}
end

-- ISLSkillGraph.load(path) -> error, ISLSkillGraph
function ISLSkillGraph.load(path)
   local err, graph = nil, nil
   if not path then
      return ISLLog.error(err_msg.GRAPH_FILE_BAD_PATH), nil
   end

   local graph_config = root.assetJson(path)
   if not graph_config then
      return ISLLog.error(err_msg.GRAPH_FILE_NOT_FOUND, path), nil
   end

   ISLLog.info("Initializing Skill Graph")
   graph = ISLSkillGraph.new()
   graph:load_modules(graph_config.skillModules.common)
   graph:load_modules(
      graph_config.skillModules.species[player.species()] or graph_config.skillModules.species.default
   )

   return nil, graph
end

-- Methods --------------------------------------------------------------------

function ISLSkillGraph:load_modules(bindings)
   bindings = bindings or {}

   for module_id, binding in pairs(bindings) do
      if not binding or not binding.path then
         ISLLog.error(err_msg.BAD_MODULE_BINDING,module_id)
      else
         binding = ISLSkillModuleBinding.new(binding)

         local err, skill_module = binding:load_skill_module()

         if err then
            ISLLog.error(err)
         elseif not skill_module then
            ISLLog.error("Bad module data trying to load '%s'", module_id)
         else
            self.loaded_modules[module_id] = binding

            for skill_id, skill in pairs(skill_module.get_skills()) do
               if self.skills[skill_id] then
                  ISLLog.warn(
                     "Overwrote skill '%s' while loading Skill Module '%s'",
                     skill_id,
                     self.name
                  )
               end
            end
         end
      end
   end

   return self;
end
