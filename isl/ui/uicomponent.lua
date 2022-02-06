--[[
   Common UI Component logic as an abstract class
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")

-- Constants ------------------------------------------------------------------

DOUBLE_CLICK_DISTANCE_TOLERANCE = 1
DOUBLE_CLICK_TIME_TOLERANCE = 0.5

-- Class ----------------------------------------------------------------------

UIComponent = createClass("UIComponent")

-- Constructor ----------------------------------------------------------------
function UIComponent:init()
   self.children = {}
end

-- Abstract Methods -----------------------------------------------------------

function UIComponent:addChild(key, component)
   self.children = self.children or {}
   self.children[key] = component
end
function UIComponent:removeChild(key)
   self.children = self.children or {}
   self.children[key] = nil
end

function UIComponent:draw(...)
   self:drawChildren(...)
end

function UIComponent:drawChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["draw"] ~= nil then
         child:draw(...)
      end
   end
end

function UIComponent:update(...)
   self:updateChildren(...)
end

function UIComponent:updateChildren(... --[[dt, ...]])
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["update"] ~= nil then
         child:update(...)
      end
   end
end

function UIComponent:createTooltip(... --[[mouse_position, ...]])
   return self:createTooltipsForChildren(...)
end

function UIComponent:createTooltipsForChildren(... --[[mouse_position, ...]])
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["createTooltip"] ~= nil then
         local res = child:createTooltip(...)

         if res ~= nil then
            return res
         end
      end
   end
end

function UIComponent:handleMouseEvent(mouse_position, ...)
   local position = Point.new(mouse_position)
   self:handleMouseEventForChildren(position, ...)
end

function UIComponent:handleMouseEventForChildren(mouse_position, button, pressed, ...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseEvent"] ~= nil then
         child:handleMouseEvent(mouse_position, button, pressed, ...)
      end
   end
end

function UIComponent:handleMouseClick(...)
   self:handleMouseClickForChildren(...)
end

function UIComponent:handleMouseClickForChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseClick"] ~= nil then
         child:handleMouseClick(...)
      end
   end
end

function UIComponent:handleMouseDoubleClick(...)
   self:handleMouseDoubleClickForChildren(...)
end

function UIComponent:handleMouseDoubleClickForChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseDoubleClick"] ~= nil then
         child:handleMouseDoubleClick(...)
      end
   end
end

-- Subclass -------------------------------------------------------------------
UIComponentWithMouseState = defineSubclass(UIComponent, "UIComponentWithMouseState") {
   mouse = {
      last_position = Point.new({ 0, 0 }),
      last_clicked_position = Point.new({ 0, 0 }),
      position = Point.new({ 0, 0 }),
      last_clicked_time = os.clock(),
      clicked_time = os.clock(),
      last_pressed = false,
      pressed = false
   }
}

function UIComponentWithMouseState:handleMouseEvent(position, button, pressed, ...)
   self.mouse.last_pressed = self.mouse.pressed
   self.mouse.pressed = pressed
   self.mouse.last_position = self.mouse.position
   self.mouse.position = position

   self:handleMouseEventForChildren(position, button, pressed, ...)

   if pressed then
      -- If the mouse IS pressed,
      -- and the pressed button is the left mouse button
      if button == 0 then
         -- If it wasn't pressed before,
         self.mouse.last_clicked_time = self.mouse.clicked_time
         self.mouse.clicked_time = os.clock()

         -- Check for double clicks
         local distance = position:translate(self.mouse.last_position:inverse()):mag()
         local time_elapsed = os.clock() - self.mouse.last_clicked_time
         local is_fast_enough = time_elapsed <= DOUBLE_CLICK_TIME_TOLERANCE
         local is_close_enough = distance <= DOUBLE_CLICK_DISTANCE_TOLERANCE
         local is_double_click = is_fast_enough and is_close_enough

         if is_double_click then
            self:handleMouseDoubleClick(position, button, ...)
         else
            self:handleMouseClick(position, button, ...)
         end
      end
   end
end
