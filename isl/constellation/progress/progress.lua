--[[
   Interface component logic for the IntoStarlight Constellation
   Player progress bar
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/uicomponent.lua")

-- Constants ------------------------------------------------------------------
local Widgets = {}
Widgets.MotesCount = "motes_count_label"
Widgets.ProgressBar = "progress_bar_image"

-- Class ----------------------------------------------------------------------

UIConstellationProgress = defineSubclass(UIComponent, "UIConstellationProgress")()

-- Constructor ----------------------------------------------------------------

function UIConstellationProgress:init(layout_id)
   if not Strings then ISLStrings.initialize() end
   self.layout_id = layout_id

   UIComponent.init(self)
end

-- Methods --------------------------------------------------------------------

function UIConstellationProgress:draw()
   widget.setText(
      self.layout_id..'.'..Widgets.MotesCount,
      player.currency("isl_skill_mote")
   )
end

function UIConstellationProgress:update()
  self:draw()
end
