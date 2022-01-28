--[[
   Interface component logic for the IntoStarlight Character Sheet
   Player Info panel
]]
require("/scripts/questgen/util.lua")
require("/isl/strings.lua")

-- Constants ------------------------------------------------------------------
local Widgets = {}
Widgets.Title = "title"
Widgets.Description = "infoPanel.text"

-- Class ----------------------------------------------------------------------

PlayerInfoPanelUI = createClass("PlayerInfoPanelUI")

-- Constructor ----------------------------------------------------------------

function PlayerInfoPanelUI:init()
   if not Strings then Strings.initialize() end
end

-- Methods --------------------------------------------------------------------

function PlayerInfoPanelUI:draw()
   widget.setText(
      Widgets.Title,
      Strings.PlayerInfoPanel.header[Strings.locale]
   )
   widget.setText(
      Widgets.Description,
      Strings.PlayerInfoPanel.description[Strings.locale]
   )
end

function PlayerInfoPanelUI:update(--[[dt : number]]) end
