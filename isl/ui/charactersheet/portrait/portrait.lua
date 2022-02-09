--[[
   A UI component for rendering the player's portrait to a Canvas
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/ui/uicomponent.lua")

UIPortraitType = {}
-- Just the head, no armor/clothing
UIPortraitType.HEAD = "head"
-- Just the head, with armor/clothing
UIPortraitType.BUST = "bust"
UIPortraitType.NEUTRAL = "neutral"
UIPortraitType.FULL = "full"
UIPortraitType.FULL_NUDE = "fullnude"
UIPortraitType.FULL_NEUTRAL = "fullneutral"
UIPortraitType.FULL_NEUTRAL_NUDE = "fullneutralnude"


UIPortrait = defineSubclass(UIComponent, "UIPortrait")()

function UIPortrait:init(widget_id, portrait_type, is_debug)
   self.children = {}

   self.canvas = widget.bindCanvas(widget_id)

   if not self.canvas then
      ISLLog.error("Failed to bind canvas to widget '%s'", widget_id)
   end

   self.canvas_size = Point.new(widget.getSize(widget_id))
   self.canvas_bounds = Bounds.new({0, 0}, self.canvas_size)
   self.portrait_type = portrait_type
   self.is_debug = is_debug
end

function UIPortrait:draw()
   self.canvas:clear()

   local layers = world.entityPortrait(player.id(), self.portrait_type)

   for _, layer in ipairs(layers) do
      local scale = 1
      local position = Point.new({
         layer.transformation[1][3],
         layer.transformation[2][3]
      })

      if self.portrait_type == "head" or self.portrait_type == "bust" then
         position = position:translate({ 11, 5 })
      else
         position = position:translate({ 22, 21 })
         scale = 1.5
      end

      self.canvas:drawImage(
         layer.image,
         position,
         scale,
         "#FFFFFF",
         false
      )
   end

   if self.is_debug then
      self.canvas:drawLine(
         { 1, 1 },
         { 5, 1 },
         "#00FFFF",
         1
      )
      self.canvas:drawLine(
         { 1, 1 },
         { 1, 5 },
         "#00FFFF",
         1
      )
      self.canvas:drawLine(
         { self.canvas_size[1]-5, self.canvas_size[2]-1 },
         self.canvas_size:translate({ -1, -1 }),
         "#00FFFF",
         1
      )
      self.canvas:drawLine(
         { self.canvas_size[1]-1, self.canvas_size[2]-5 },
         self.canvas_size:translate({ -1, -1 }),
         "#00FFFF",
         1
      )
   end

   self:drawChildren()
end

function UIPortrait:update(dt)
   self:draw() -- Draw on update, so we can keep the player's portrait up to date.

   self:updateChildren(dt)
end
