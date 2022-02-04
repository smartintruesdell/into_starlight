--[[
   UISpeciesNode extends UISkillTreeNode to provide types specific rendering
   instructions for the root Species node of the Skills graph
]]
local PATH = "/isl/ui/charactersheet/components/skilltree/nodes"

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require(PATH.."/node.lua")

local Assets = nil

-- Class ----------------------------------------------------------------------

UISpeciesNode = defineSubclass(UISkillTreeNode, "UISpeciesNode")()

-- Constructor ----------------------------------------------------------------

function UISpeciesNode:init(skill, canvas)
   Assets = Assets or root.assetJson(PATH.."/species_node_assets.config")
   self.defaultBackground = Assets.background.default
   self.defaultIcon = Assets.icon.default
   self.defaultMask = Assets.mask.default
   UISkillTreeNode.init(self, skill, canvas) -- super()

   assert(
      self.skill.type == "species",
      string.format(
         "Tried to render a '%s' skill as a Species node",
         self.skill.type
      )
   )
end

-- Methods --------------------------------------------------------------------

function UISpeciesNode:draw(skilltree_state)
   if not self.canvas.bounds:collides_bounds(self.bounds) then
      return
   end

   UISkillTreeNode.draw(self, skilltree_state)

   local target_position = self.skill.position:translate(skilltree_state.offset)

   if not self.has_custom_background then
      -- Now, if we're not using a customized graphic we're going to print
      -- the base Strength/Precision/Wits values onto the frame.
      self.canvas:drawText(
         "^shadow;"..self.skill.stats.strength,
         {
            position = target_position:translate({ 0, 32 }),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
         }
      )

      self.canvas:drawText(
         "^shadow;"..self.skill.stats.precision,
         {
            position = target_position:translate(Point.new({ 0, 32 }):rotate(120)),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
         }
      )

      self.canvas:drawText(
         "^shadow;"..self.skill.stats.wits,
         {
            position = target_position:translate(Point.new({ 0, 32 }):rotate(240)),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
         }
      )
   end
end
