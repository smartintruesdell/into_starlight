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

ISLStrings = ISLStrings or Load_ISL_Strings()

-- Class ----------------------------------------------------------------------

PlayerInfoPanelUI = createClass("PlayerInfoPanelUI")

-- Constructor ----------------------------------------------------------------

function PlayerInfoPanelUI:init()
end

-- Methods --------------------------------------------------------------------

function PlayerInfoPanelUI:draw()
   widget.setText(
      Widgets.Title,
      ISLStrings.PlayerInfoPanel.header[ISLStrings.locale]
   )
   widget.setText(
      Widgets.Description,
      ISLStrings.PlayerInfoPanel.header[ISLStrings.locale]
   )
end

function PlayerInfoPanelUI:update(--[[dt : number]]) end
