--[[
   UISpeciesNode extends UISkillTreeNode to provide types specific rendering
   instructions for the root Species node of the Skills graph
]]
local PATH = "/isl/constellation/skilltree/nodes"

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
   local canvas_bounds = Bounds.new(
      {0, 0},
      self.canvas:size()
   )
   if not canvas_bounds:collides_bounds(self.bounds) then
      return
   end

   UISkillTreeNode.draw(self, skilltree_state)

   local target_position = self.skill.position:translate(skilltree_state.drag_offset)

   if not self.has_custom_background then
      -- Now, if we're not using a customized graphic we're going to print
      -- the base Strength/Precision/Wits values onto the frame.
      local font_size = 7
      local strength = self.skill.unlocks.stats.isl_strength.amount or 0
      self.canvas:drawText(
         "^shadow;^#ffd752;"..strength,
         {
            position = target_position:translate({ 0, 28 }),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
         },
         font_size
      )

      local precision = self.skill.unlocks.stats.isl_precision.amount or 0
      self.canvas:drawText(
         "^shadow;^#51b9ff;"..precision,
         {
            position = target_position:translate(Point.new({ 0, 29 }):rotate(120)),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
         },
         font_size
      )

      local wits = self.skill.unlocks.stats.isl_wits.amount or 0
      self.canvas:drawText(
         "^shadow;^#3fe8ae;"..wits,
         {
            position = target_position:translate(Point.new({ 0, 29 }):rotate(240)),
            horizontalAnchor = "mid",
            verticalAnchor = "mid"
         },
         font_size
      )
   end
end
