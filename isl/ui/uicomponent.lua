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
   self:createTooltipsForChildren(mouse_position)
end

function UIComponent:createTooltipsForChildren(mouse_position)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["createTooltip"] ~= nil then
         child:createTooltip(mouse_position)
      end
   end
end

function UIComponent:handleMouseEvent(mouse_position, button, pressed)
   self:handleMouseEventForChildren(mouse_position, button, pressed)
end

function UIComponent:handleMouseEventForChildren(mouse_position, button, pressed)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleMouseEvent"] ~= nil then
         child:handleMouseEvent(mouse_position, button, pressed)
      end
   end
end

function UIComponent:handleWidgetClicked(widget_id)
   self:handleWidgetClickedForChildren(widget_id)
end

function UIComponent:handleWidgetClickedForChildren(widget_id)
   for _, child in pairs(self.children or {}) do
      if child ~= nil and child["handleWidgetClicked"] ~= nil then
         child:handleWidgetClicked(widget_id)
      end
   end
end
