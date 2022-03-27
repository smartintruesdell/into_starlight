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
require("/isl/lib/point.lua")
require("/isl/skillgraph/skill.lua")
require("/isl/skillgraph/skillmodulebinding.lua")

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
   self.position = Point.new(data.position or {0,0})
   -- number - (degrees) A rotation to apply when positioning children
   self.rotation = data.rotation or 0.0
   -- number - A scale number to apply to distances from the origin.
   self.scale = data.scale or 1.0
end

-- Methods --------------------------------------------------------------------

--- Applies Scale/Rotate/Translate all in one
function ISLSkillModule:transform(dt, dr, ds)
   dt = dt or Point.new({ 0, 0 })
   dr = dr or 0
   ds = ds or 1

   local updated_children = {}
   for child_id, child in pairs(self.children or {}) do
      updated_children[child_id] = child:transform(dt, dr)
   end

   return ISLSkillModule.new(
      {
         name = self.name,
         skills = self.skills,
         children = updated_children,
         position = self.position:translate(dt),
         rotation = self.rotation + dr % 360,
         scale = self.scale * ds
      }
   )
end

-- Static Functions -----------------------------------------------------------

--- Reads SkillModule data from a JSON asset
--- load_from_path(string) -> (error, ISLSkillModule)
function ISLSkillModule.load_from_path(path)
  local file_data = root.assetJson(path)

   local new_module = ISLSkillModule.new({
      name = file_data.name,
      position = file_data.position,
      rotation = file_data.rotation,
      scale = file_data.scale
   })

   ISLLog.debug("Loading Skill Module '%s'", new_module.name)

   for skill_id, skill_data in pairs(file_data.skills) do
      skill_data.id = skill_id
      new_module.skills[skill_id] = ISLSkill.from_module(skill_data)
   end

   for child_id, binding in pairs(file_data.children) do
      local child_module = ISLSkillModuleBinding.new(binding):load_skill_module()

      new_module.children[child_id] = child_module
   end

   return new_module
end

-- Methods --------------------------------------------------------------------

--- Recursively picks skills from this SkillModule and its children
function ISLSkillModule:get_skills()
   local skills = {}

   for skill_id, skill in pairs(self.skills) do
      if skills[skill_id] then
         ISLLog.warn(
            "Overwrote skill '%s' while loading Module '%s'",
            skill_id,
            self.name
         )
      end

      skills[skill_id] = skill:transform(self.position, self.rotation, self.scale)
   end

   for _, sub_module in pairs(self.children) do
      for skill_id, skill in pairs(sub_module:get_skills()) do
         if skills[skill_id] then
         ISLLog.warn(
            "Overwrote skill '%s' while loading Module '%s'",
            skill_id,
            sub_module.name
         )
         end

         skills[skill_id] = skill:transform(self.position, self.rotation)
      end
   end

   return skills
end
