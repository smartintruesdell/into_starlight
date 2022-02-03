--[[
   UISpeciesNode extends UIComponent to provide types specific rendering
   instructions for the root Species node of the Skills graph
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/ui/uicomponent.lua")

local PATH = "/isl/ui/charactersheet/components/skilltree/nodes"
local Assets = {}
Assets.background = PATH.."/assets/graph_species.png"
Assets.icon = PATH.."/assets/graph_species_default.png"
Assets.mask = PATH.."/assets/graph_species_mask.png"

local DEFAULT_COLOR = "#FFFFFF"

-- Class ----------------------------------------------------------------------

UISpeciesNode = defineSubclass(UIComponent, "UISpeciesNode")()

-- Constructor ----------------------------------------------------------------

function UISpeciesNode:init(skill, canvas)
   self.skill = skill
   self.canvas = canvas
   assert(
      self.skill.type == "species",
      string.format(
         "Tried to render a '%s' skill as a Species node",
         self.skill.type
      )
   )
   assert(
      self.canvas ~= nil,
      "Unable to bind a valid canvas for a Species Node"
   )

   self.background = skill.background or Assets.background
   self.has_custom_background = skill.background ~= nil

   self.radius = root.imageSize(self.background)[1] * 0.5
   self.bounds = Bounds.new(
      skill.position:translate({ -1 * self.radius, -1 * self.radius }),
      skill.position:translate({ self.radius, self.radius })
   )
end

-- Methods --------------------------------------------------------------------

function UISpeciesNode:draw(drag_state)
   -- If we're not close enough to the viewable area to be drawn, skip.
   if not self.canvas.bounds:collides_bounds(self.bounds) then
      return
   end

   local target_position = self.skill.position:translate(drag_state.offset)

   -- Draw a skill-defined background or the default Species node background
   self.canvas:drawImage(
      self.background,
      target_position,
      1,
      DEFAULT_COLOR,
      true
   )

   -- Draw a skill-defined icon or the default Species node icon
   local icon_image = (self.skill.icon or Assets.icon)
   if not self.has_custom_background then
      -- If we're using the default background, then we're going to go ahead
      -- and MASK the icon image so that it doesn't overrun the frame.
      icon_image = icon_image.."?addmask="..Assets.mask
   end
   self.canvas:drawImage(
      icon_image,
      target_position,
      1,
      DEFAULT_COLOR,
      true
   )

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

--- Species nodes are circular, and so must calculate mouseovers and clicks
--- based on their circular area rather than using simple rectangular bounds.
function UISpeciesNode:area_contains_position(position)
   -- Offset such that skill.positioin is 0,0
   local relative_point = Point.new(position):translate(self.skill.position:inverse())
   -- Then distance by the Pythagorean theorum
   local distance = math.sqrt((relative_point[1]^2)+(relative_point[2]^2))

   return distance <= self.radius
end
