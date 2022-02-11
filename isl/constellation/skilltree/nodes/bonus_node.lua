--[[
  UIBonusNode extends UIComponent to provide types specific rendering
  instructions for Bonus nodes of the Skills graph
]]
local PATH = "/isl/constellation/skilltree/nodes"

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require(PATH.."/node.lua")

local Assets = nil

-- Class ----------------------------------------------------------------------

UIBonusNode = defineSubclass(UISkillTreeNode, "UIBonusNode")()

-- Constructor ----------------------------------------------------------------

function UIBonusNode:init(skill, canvas)
  Assets = Assets or root.assetJson(PATH.."/bonus_node_assets.config")
  self.defaultBackground = Assets.background.default

  -- Validations
  assert(skill ~= nil, "Tried to instantiate a UIBonusNode without a Skill")
  assert(
    skill.type == "bonus",
    string.format(
      "Tried to render a '%s' skill as a Bonus node",
      skill.type
    )
  )

  UISkillTreeNode.init(self, skill, canvas) -- super

  -- Set the background based on the bonus type
  self.background = skill.background or Assets.background[skill.background_type]
  assert(self.background ~= nil, "failed to find a background for "..skill.id)
end

-- Overrides -----------------------------------------------------------------

function UIBonusNode:get_background_image(skilltree_state)
  assert(SkillGraph ~= nil, "Tried to draw nodes without a valid SkillGraph")
  local background_image = nil
  if SkillGraph.unlocked_skills:contains(self.skill.id) then
    if SkillGraph.saved_skills:contains(self.skill.id) then
      background_image = self.background..":saved"
    else
      background_image = self.background..":new"
    end
  elseif SkillGraph.available_skills:contains(self.skill.id) ~= nil then
    background_image = self.background..":available"
  else
    background_image = self.background..":unavailable"
  end
  return background_image
end

-- Methods --------------------------------------------------------------------
