--[[
   Stats display subcomponent for the Character Sheet
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/util.lua")
require("/isl/strings.lua")
require("/isl/bounds.lua")
require("/isl/ui/uicomponent.lua")
require("/isl/ui/charactersheet/components/portrait/portrait.lua")

-- Class ----------------------------------------------------------------------

UICharacterSheetStats = defineSubclass(UIComponent, "UICharacterSheetStats")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheetStats:init(layout_id)
   if not Strings.ready then Strings.init() end

   self.layout_id = layout_id
   self:addChild("portrait", UIPortrait.new(layout_id..".portrait", "full"))
end

function UICharacterSheetStats:createTooltip(mouse_position)
   --ISLLog.debug('createTooltip called for UICharacterSheetStats');

   if (widget.inMember(self.layout_id, mouse_position)) then
      for child_id, child in pairs(config.getParameter("gui."..self.layout_id..".children")) do
         if widget.inMember(self.layout_id.."."..child_id, mouse_position) then
            if child.tooltipStringId then
               return Strings.getString(child.tooltipStringId)
            end
         end
      end
   end

   self:createTooltipsForChildren(mouse_position)
end
