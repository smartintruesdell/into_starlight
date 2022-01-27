--[[
   An ISLSkillModuleBinding positions an ISLSkillModule relative to its parents.
]]
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/skillmodule/skillmodule.lua")

-- Constants ------------------------------------------------------------------

local err_msg = {}
err_msg.MODULE_DATA_NOT_FOUND = ".skillmodule not found at '%s'"

-- Class ----------------------------------------------------------------------

--- Models the position/rotation of an IntoStarlight SkillModule
ISLSkillModuleBinding = createClass("ISLSkillModuleBinding")

--- Constructor
function ISLSkillModuleBinding:init(data)
   -- string - The path to a .skillmodule file
   self.path = data.path or ""
   -- Point - The relative position of the root node of this module
   self.position = Point.new(data.position or {0,0})
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
         translation = Point.new({
               self.translation[1] + dt[1],
               self.translation[2] + dt[2]
         }),
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

--- ISLSkillModuleBinding:load_skill_module() -> (error, ISLSkillModule)
function ISLSkillModuleBinding:load_skill_module()
   local err, skill_module = ISLSkillModule.load_from_path(self.path)

   skill_module = skill_module:transform(
      self.translation,
      self.rotation,
      self.scale
   )

   return err, skill_module
end
