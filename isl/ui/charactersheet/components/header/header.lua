--[[
   Interface component logic for the IntoStarlight Character Sheet
   Player Info panel
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/util.lua")
require("/isl/strings.lua")
require("/isl/ui/uicomponent.lua")

-- Constants ------------------------------------------------------------------
local Widgets = {}
Widgets.PlayerName = "playerName"
Widgets.PlayerNameShadow = "playerName_shadow"
Widgets.Subtitle = "subtitle"
Widgets.SubtitleShadow = "subtitle_shadow"
Widgets.Description = "infoPanel.text"
Widgets.Portrait = "portrait"

-- Class ----------------------------------------------------------------------

UICharacterSheetHeader = defineSubclass(UIComponent, "UICharacterSheetHeader")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheetHeader:init()
   if not Strings then Strings.initialize() end
   self.children = {}

   self:addChild("portrait", UIPortrait.new("portrait", "bust"))
end

-- Methods --------------------------------------------------------------------

function UICharacterSheetHeader:draw()
   widget.setText(
      Widgets.PlayerName,
      "^shadow;"..world.entityName(player.id())
   )
   widget.setText(
      Widgets.Subtitle,
      Strings.PlayerInfoPanel.subtitle[Strings.locale]
   )
   widget.setText(
      Widgets.Description,
      Strings.PlayerInfoPanel.description[Strings.locale]
   )

   self:drawChildren()
end
