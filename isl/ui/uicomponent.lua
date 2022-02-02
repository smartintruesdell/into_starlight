--[[
   Common UI Component logic for subclassing
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")

UIComponent = createClass("UIComponent")

function UIComponent:init()
   self.children = {}
end

function UIComponent:addChild(key, component)
   self.children = self.children or {}
   self.children[key] = component
end
function UIComponent:removeChild(key)
   self.children = self.children or {}
   self.children[key] = nil
end

function UIComponent:draw()
   self:drawChildren()
end

function UIComponent:drawChildren()
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["draw"] ~= nil then
         child:draw()
      end
   end
end

function UIComponent:update(dt)
   self:updateChildren(dt)
end

function UIComponent:updateChildren(dt)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["update"] ~= nil then
         child:update(dt)
      end
   end
end

function UIComponent:createTooltip(mouse_position)
   return self:createTooltipsForChildren(mouse_position)
end

function UIComponent:createTooltipsForChildren(mouse_position)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["createTooltip"] ~= nil then
         local res = child:createTooltip(mouse_position)

         if res ~= nil then
            return res
         end
      end
   end
end

function UIComponent:handleMouseEvent(mouse_position, button, is_down)
   --ISLLog.debug("Handle Mouse Event Clicked(%s) %s, %s, %s", self.className, mouse_position, button, is_down)
   self:handleMouseEventForChildren(mouse_position, button, is_down)
end

function UIComponent:handleMouseEventForChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseEvent"] ~= nil then
         child:handleMouseEvent(...)
      end
   end
end

function UIComponent:handleWidgetClicked(...)
   self:handleWidgetClickedForChildren(...)
end

function UIComponent:handleWidgetClickedForChildren(...)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleWidgetClicked"] ~= nil then
         child:handleWidgetClicked(...)
      end
   end
end
