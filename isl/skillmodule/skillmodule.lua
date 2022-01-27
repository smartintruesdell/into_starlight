--[[
   Skill Modules are an astraction over a set of skills to make managing
   those skills easier.

   Specifying skill positions and relative values requires expensive
   brainpower and a lot of it can be automated for consistency, stability,
   and general usability.

   Define a skill module to add skills to the skill graph without all the
   hassle.
]]
require("/scripts/questgen/util.lua")
require("/isl/point.lua")
require("/isl/skill/skill.lua")
require("/isl/skillmodule/skillmodulebinding.lua")

-- Constants ------------------------------------------------------------------

local err_msg = {}
err_msg.NOT_FOUND = ".skillmodule not found at '%s'"

-- Configuration --------------------------------------------------------------

-- Class ----------------------------------------------------------------------

--- Models an IntoStarlight SkillModule
ISLSkillModule = createClass("ISLSkillModule")

--- Constructor
function ISLSkillModule:init(data)
   --- : string - The (internal) id of this module, mostly used for debugging
   self.name = data.name or ""

   --- : table<string, ISLSkill> - The Skills contained within this module
   self.skills = data.skills or {}

   --- : table<string, ISLSkillModuleBinding>
   --- - Any sub-modules contained within this module
   self.children = data.children or {}

   -- Note: The following properties are typically set on the
   -- ISLSkillModuleBinding rather than on the ISLSkillModule itself.

   -- Point - The relative position of the root node of this module on the graph
   self.position = Point.new(data.translation or {0,0})
   -- number - (degrees) A rotation to apply when positioning children
   self.rotation = data.rotation or 0.0
   -- number - A scale number to apply to distances from the origin.
   self.scale = data.scale or 1.0
end

-- Methods --------------------------------------------------------------------

--- Applies Scale/Rotate/Translate all in one
function ISLSkillModule:transform(translation, rotation, scale)
   translation = translation or Point.new({ 0, 0 })
   rotation = rotation or 0
   scale = scale or 1

   return self:scale(scale):rotate(rotation):translate(translation)
end

--- Updates the position of the skill module by applying a translation
function ISLSkillModule:translate(dt)
   dt = dt or Point.new({ 0, 0 })

   local updated_children = {}
   for child_id, child in pairs(self.children) do
      updated_children[child_id] = child.translate(dt)
   end

   return ISLSkillModule.new(
      {
         name = self.name,
         skills = self.skills,
         children = updated_children,
         position = self.position:translate(dt),
         rotation = self.rotation,
         scale = self.scale
      }
   )
end

--- Updates the position of the skill module by applying a rotation
function ISLSkillModule:rotate(dr)
   dr = dr or 0

   local updated_children = {}
   for child_id, child in pairs(self.children) do
      updated_children[child_id] = child.rotate(dr)
   end

   return ISLSkillModule.new(
      {
         name = self.name,
         skills = self.skills,
         children = updated_children,
         position = self.position,
         rotation = (self.rotation + dr) % 360,
         scale = self.scale
      }
   )
end

--- Updates the position of the skill module by applying a scale
--- NOTE: Scale does not propagate to children
function ISLSkillModule:scale(ds)
   ds = ds or 1

   return ISLSkillModule.new(
      {
         name = self.name,
         skills = self.skills,
         children = self.children,
         position = self.position,
         rotation = (self.rotation + dr) % 360,
         scale = self.scale * ds
      }
   )
end

-- Static Functions -----------------------------------------------------------

--- Reads SkillModule data from a JSON asset
--- load_from_path(string) -> (error, ISLSkillModule)
function ISLSkillModule.load_from_path(path)
   local file_data = root.assetJson(path)

   if not file_data then
      return ISLLog.error(err_msg.NOT_FOUND, path), nil
   end

   local new_module = {
      name = file_data.name,
      skills = {},
      children = {}
   }

   for skill_id, skill_data in pairs(file_data.skills) do
      new_module.skills[skill_id] = ISLSkill.new(skill_data)
   end

   for child_id, binding in pairs(file_data.children) do
      local err, child_module = ISLSkillModuleBinding.new(binding):load_skill_module()

      if err then
         ISLLog.error(err)
      else
         new_module.children[child_id] = child_module
      end
   end

   ISLLog.debug("Loaded Skill Module '%s'", new_module.name)
   return nil, new_module
end

-- Methods --------------------------------------------------------------------

--- Recursively picks skills from this SkillModule and its children
function ISLSkillModule:get_skills()
   local skills = {}

   local function add_skill(module_name, skill_id, skill)
      if skills[skill_id] then
         ISLLog.warn(
            "Overwrote skill '%s' while loading Module '%s'",
            skill_id,
            module_name
         )
      end
      skills[skill_id] = skill
   end

   for skill_id, skill in pairs(self.skills) do
      add_skill(
         self.name,
         skill_id,
         skill:translate(self.position, self.rotation, self.scale)
      )
   end

   for _, sub_module in pairs(self.children) do
      for skill_id, skill in pairs(sub_module:get_skills(skills)) do
         add_skill(
            sub_module.name,
            skill_id,
            skill:translate(self.position, self.rotation, 1) -- don't propagate scale
         )
      end
   end

   return skills
end
