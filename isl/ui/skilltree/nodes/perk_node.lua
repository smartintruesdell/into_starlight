--[[
   UIPerkNode extends UISkillTreeNode to provide types specific rendering
   instructions for the root Species node of the Skills graph
]]
local PATH = "/isl/ui/skilltree/nodes"

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
   self.defaultIcon = Assets.icon.default
   self.defaultMask = Assets.mask.default
   UISkillTreeNode.init(self, skill, canvas) -- super()

   assert(
      self.skill.type == "perk",
      string.format(
         "Tried to render a '%s' skill as a Perk node",
         self.skill.type
      )
   )
end
