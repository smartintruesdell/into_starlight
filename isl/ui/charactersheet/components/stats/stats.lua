--[[
   Stats display subcomponent for the Character Sheet
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/util.lua")
require("/isl/strings.lua")
require("/isl/bounds.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/stats/stats.lua")
require("/isl/ui/uicomponent.lua")
require("/isl/ui/charactersheet/components/portrait/portrait.lua")
require("/isl/ui/charactersheet/components/stats/stat_text.lua")

-- Class ----------------------------------------------------------------------

UICharacterSheetStats = defineSubclass(UIComponent, "UICharacterSheetStats")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheetStats:init(layout_id)
   if not Strings.ready then Strings.init() end

   self.stats = ISLStats.new()

   self.layout_id = layout_id
   self:addChild("portrait", UIPortrait.new(layout_id..".portrait", "full"))
   self:addChild("portrait", UIPortrait.new(layout_id..".portrait", "full"))
   self:addChild(
      "isl_strength_text",
      UICharacterSheetStatText.new(
         "isl_strength",
         true,
         layout_id
      )
   )
   self:addChild(
      "isl_precision_text",
      UICharacterSheetStatText.new(
         "isl_precision",
         true,
         layout_id
      )
   )
   self:addChild(
      "isl_wits_text",
      UICharacterSheetStatText.new(
         "isl_wits",
         true,
         layout_id
      )
   )
   self:addChild(
      "isl_defense_text",
      UICharacterSheetStatText.new(
         "isl_defense",
         false,
         layout_id
      )
   )
   self:addChild(
      "isl_evasion_text",
      UICharacterSheetStatText.new(
         "isl_evasion",
         false,
         layout_id
      )
   )
   self:addChild(
      "isl_energy_text",
      UICharacterSheetStatText.new(
         "isl_energy",
         false,
         layout_id
      )
   )
end

function UICharacterSheetStats:createTooltip(mouse_position)
   --ISLLog.debug('createTooltip called for UICharacterSheetStats');

   if (widget.inMember(self.layout_id, mouse_position)) then
      for child_id, child in pairs(config.getParameter("gui."..self.layout_id..".children")) do
         if child.tooltipStringId then
            if widget.inMember(self.layout_id.."."..child_id, mouse_position) then
               return Strings.getString(child.tooltipStringId)
            end
         end
      end
   end

   self:createTooltipsForChildren(mouse_position)
end
