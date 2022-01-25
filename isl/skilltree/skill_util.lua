require("/isl/bounds.lua")

-- Preventing potential overrides
SkillUtil = SkillUtil or {}

-- Constants ------------------------------------------------------------------

SkillUtil.SKILL_TYPE = {}
SkillUtil.SKILL_TYPE.SPECIES = "species"
SkillUtil.SKILL_TYPE.PERK = "perk"
SkillUtil.SKILL_TYPE.SKILL = "skill"

-- Functions ------------------------------------------------------------------

--- Returns bounds for use in computing icon position
function SkillUtil.get_skill_icon_bounds(skill_data, icon_sizes)
   local icon_size = icon_sizes[skill_data.type]

   return Bounds(
      skill_data.position[1] + (icon_size * 0.5),
      skill_data.position[2] + (icon_size * 0.5),
      skill_data.position[1] + (icon_size * 1.5),
      skill_data.position[2] + (icon_size * 1.5)
   )
end
