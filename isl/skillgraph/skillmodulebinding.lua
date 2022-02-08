--[[
   An ISLSkillModuleBinding positions an ISLSkillModule relative to its parents.
]]
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/lib/point.lua")
require("/isl/skillgraph/skillmodule.lua")

-- Class ----------------------------------------------------------------------

--- Models the position/rotation of an IntoStarlight SkillModule
ISLSkillModuleBinding = createClass("ISLSkillModuleBinding")

--- Constructor
function ISLSkillModuleBinding:init(data)
   -- string - The path to a .skillmodule file
   self.path = data.path or ""
   -- Point - The relative position of the root node of this module
   self.translation = Point.new(data.translation or {0,0})
   -- number - (degrees) A rotation to apply when positioning children
   self.rotation = data.rotation or 0.0
   -- number - A scale number to apply to distances from the origin.
   self.scale = data.scale or 1.0
end

-- Methods --------------------------------------------------------------------

--- Translate a binding, used to apply parent transforms to children
function ISLSkillModuleBinding:translate(dt)
   return ISLSkillModuleBinding.new(
      {
         path = self.path,
         translation = self.translation:translate(dt),
         rotation = self.rotation,
         scale = self.scale
      }
   )
end

--- Rotate a binding, used to apply parent transforms to children
function ISLSkillModuleBinding:rotate(dr)
   return ISLSkillModuleBinding.new(
      {
         path = self.path,
         translation = self.translation,
         rotation = (self.rotation + dr) % 360,
         scale = self.scale
      }
   )
end

--- ISLSkillModuleBinding:load_skill_module() -> ISLSkillModule
function ISLSkillModuleBinding:load_skill_module()
   local skill_module = ISLSkillModule.load_from_path(self.path)

   if not skill_module then
      ISLLog.error("Failed to load skill module from '%s'", self.path)
   end

   return skill_module:transform(
      self.translation,
      self.rotation,
      self.scale
   )
end
