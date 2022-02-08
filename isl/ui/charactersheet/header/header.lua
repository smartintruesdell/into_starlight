--[[
   Interface component logic for the IntoStarlight Character Sheet
   Player Info panel
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/constants/strings.lua")
require("/isl/ui/uicomponent.lua")
require("/isl/ui/charactersheet/portrait/portrait.lua")

-- Constants ------------------------------------------------------------------
local Widgets = {}
Widgets.PlayerName = "playerName"
Widgets.Subtitle = "subtitle"
Widgets.Portrait = "portrait"

-- Class ----------------------------------------------------------------------

UICharacterSheetHeader = defineSubclass(UIComponent, "UICharacterSheetHeader")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheetHeader:init(layout_id)
   if not Strings then ISLStrings.initialize() end
   self.layout_id = layout_id
   self.children = {}

   self:addChild("portrait", UIPortrait.new(layout_id..".portrait", "bust"))
end

-- Methods --------------------------------------------------------------------

function UICharacterSheetHeader:draw()
   widget.setText(
      self.layout_id..'.'..Widgets.PlayerName,
      "^shadow;"..world.entityName(player.id())
   )
   widget.setText(
      self.layout_id..'.'..Widgets.Subtitle,
      Strings:getString("charactersheet_subtitle")
   )

   self:drawChildren()
end
