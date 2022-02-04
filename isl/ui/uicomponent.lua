--[[
   Common UI Component logic as an abstract class
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")

-- Constants ------------------------------------------------------------------

DOUBLE_CLICK_DISTANCE_TOLERANCE = 1
DOUBLE_CLICK_TIME_TOLERANCE = 10

-- Class ----------------------------------------------------------------------

UIComponent = createClass("UIComponent")

-- Constructor ----------------------------------------------------------------
function UIComponent:init()
   self.children = {}
end

-- Static Properties ----------------------------------------------------------

UIComponent.mouse = {
   last_position = Point.new({ 0, 0 }),
   last_clicked_position = Point.new({ 0, 0 }),
   last_clicked_time = os.time(),
   pressed = false
}

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
   if UIComponent.mouse.pressed then
      self:handleMouseDrag(
         UIComponent.mouse.last_position,
         UIComponent.mouse.drag_start_position
      )
   end

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

function UIComponent:handleMouseEvent(mouse_position, button, pressed, ...)
   local position = Point.new(mouse_position)

   self:handleMouseEventForChildren(position, button, pressed, ...)

   if pressed and button == 0 then
      -- If we weren't pressed before, but now are, we want to start a drag maybe
      if not UIComponent.mouse.pressed then
         UIComponent.mouse.drag_start_position = position;
      end

      -- Check for double clicks
      local distance = position:translate(UIComponent.mouse.last_position:inverse()):mag()
      local time_elapsed = os.time() - UIComponent.mouse.last_clicked_time
      local is_fast_enough = time_elapsed <= DOUBLE_CLICK_TIME_TOLERANCE
      local is_close_enough = distance <= DOUBLE_CLICK_DISTANCE_TOLERANCE
      local is_double_click = is_fast_enough and is_close_enough

      if is_double_click then
         self:handleMouseDoubleClick(position, button, ...)
      else
         self:handleMouseClick(position, button, ...)
      end
   end

   UIComponent.mouse.pressed = pressed
   UIComponent.mouse.last_position = position
   UIComponent.mouse.last_clicked_time = os.time()
end

function UIComponent:handleMouseEventForChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseEvent"] ~= nil then
         child:handleMouseEvent(...)
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

function UIComponent:handleMouseDrag(...)
   self:handleMouseDragForChildren(...)
end

function UIComponent:handleMouseDragForChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseDrag"] ~= nil then
         child:handleMouseDrag(...)
      end
   end
end
