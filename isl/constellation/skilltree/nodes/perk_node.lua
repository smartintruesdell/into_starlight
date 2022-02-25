--[[
   UIPerkNode extends UISkillTreeNode to provide types specific rendering
   instructions for the root Species node of the Skills graph
]]
local PATH = "/isl/constellation/skilltree/nodes"

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require(PATH.."/node.lua")

local Assets = nil

-- Class ----------------------------------------------------------------------

UIPerkNode = defineSubclass(UISkillTreeNode, "UIPerkNode")()

-- Constructor ----------------------------------------------------------------

function UIPerkNode:init(skill, canvas)
   Assets = Assets or root.assetJson(PATH.."/perk_node_assets.config")
   self.defaultBackground = Assets.background.default

   -- Validations
   assert(skill ~= nil, "Tried to instantiate a UIPerkNode without a Skill")
   assert(
      skill.type == "perk",
      string.format(
         "Tried to render a '%s' skill as a Perk node",
         skill.type
      )
   )

   UISkillTreeNode.init(self, skill, canvas) -- super()

   -- Set the background based on the bonus type
  self.background = skill.background or Assets.background[skill.perkType]
  assert(self.background ~= nil, "Failed to find a background for "..skill.id)
end

function UIPerkNode:get_background_image(_skilltree_state)
  assert(SkillGraph ~= nil, "Tried to draw nodes without a valid SkillGraph")
  local background_image = nil
  if SkillGraph.unlocked_skills:contains(self.skill.id) then
    if SkillGraph.saved_skills:contains(self.skill.id) then
      background_image = self.background..":saved"
    else
      background_image = self.background..":new"
    end
  elseif SkillGraph.available_skills:contains(self.skill.id) then
    background_image = self.background..":available"
  else
    background_image = self.background..":unavailable"
  end
  return background_image
end
