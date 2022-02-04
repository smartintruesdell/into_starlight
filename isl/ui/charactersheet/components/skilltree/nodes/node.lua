--[[
   UISkillGraphNode extends UIComponent to provide rendering and state management
   for individual skill nodes on the skill tree
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/ui/uicomponent.lua")

local DEFAULT_COLOR = "#FFFFFF"

-- Class ----------------------------------------------------------------------

UISkillTreeNode = defineSubclass(UIComponent, "UISkillTreeNode")()

-- Constructor ----------------------------------------------------------------

function UISkillTreeNode:init(skill, canvas)
   UIComponent.init(self) -- super()

   self.skill = skill
   assert(self.skill ~= nil, "Unable to bind a valid skill for a "..self.className)
   self.canvas = canvas
   assert(self.canvas ~= nil, "Unable to bind a valid canvas for a "..self.className)

   self.background = skill.background or self.defaultBackground
   self.icon = skill.icon or self.defaultIcon
   self.mask = skill.mask or self.defaultMask or nil

   self.has_custom_background = skill.background ~= nil
   self.has_custom_icon = skill.icon ~= nil

   self.radius = root.imageSize(self.background)[1] * 0.5
   self.bounds = Bounds.new(
      skill.position:translate({ -1 * self.radius, -1 * self.radius }),
      skill.position:translate({ self.radius, self.radius })
   )
end

-- Methods --------------------------------------------------------------------

function UISkillTreeNode:draw(skilltree_state)
   -- If we're not close enough to the viewable area to be drawn, skip.
   if not self.canvas.bounds:collides_bounds(self.bounds) then
      return
   end

   local target_position = self.skill.position:translate(skilltree_state.drag_offset)

   -- Draw a skill-defined background or the default node background
   self.canvas:drawImage(
      self:get_background_image(skilltree_state),
      target_position,
      1,
      DEFAULT_COLOR,
      true
   )

   -- Draw a skill-defined icon or the default node icon
   self.canvas:drawImage(
      self.get_icon_image(skilltree_state),
      target_position,
      1,
      DEFAULT_COLOR,
      true
   )

   UIComponent.draw(self, skilltree_state)
end

function UISkillTreeNode:get_background_image(_skilltree_state)
   return self.background
end

function UISkillTreeNode:get_icon_image(_skilltree_state)
   return self.icon..(self.mask and "?addmask="..self.mask or "")
end

--- Skill tree nodes are circular, and so must calculate mouseovers and clicks
--- based on their circular area rather than using simple rectangular bounds.
function UISkillTreeNode:area_contains_position(position)
   -- Offset such that skill.position is 0,0
   local relative_point = Point.new(position):translate(self.skill.position:inverse())
   -- Then distance by the Pythagorean theorum
   local distance = math.sqrt((relative_point[1]^2)+(relative_point[2]^2))

   return distance <= self.radius
end

function UISkillTreeNode:handleMouseEvent(position, button, pressed, skilltree_state)
   -- Don't care about right clicks at the moment
   if not pressed then return end
   if button == 0 then
      -- Left click, check for double clicks.

   end
end

function UISkillTreeNode:handle_left_click() end
function UISkillTreeNode:handle_left_double_click() end
