--[[
   Interface component logic for the IntoStarlight Character Sheet
   Player Info panel
]]
require("/scripts/util.lua")
require("/isl/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/strings.lua")

-- Constants ------------------------------------------------------------------
local Widgets = {}
Widgets.PlayerName = "playerName"
Widgets.PlayerNameShadow = "playerName_shadow"
Widgets.Subtitle = "subtitle"
Widgets.SubtitleShadow = "subtitle_shadow"
Widgets.Description = "infoPanel.text"
Widgets.Portrait = "portrait"

-- Class ----------------------------------------------------------------------

PlayerInfoPanelUI = createClass("PlayerInfoPanelUI")

-- Constructor ----------------------------------------------------------------

function PlayerInfoPanelUI:init()
   if not Strings then Strings.initialize() end

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
end

-- Methods --------------------------------------------------------------------

function PlayerInfoPanelUI:draw() end

function PlayerInfoPanelUI:update(--[[dt : number]]) end
