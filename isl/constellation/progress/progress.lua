--[[
   Interface component logic for the IntoStarlight Constellation
   Player progress bar
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/util.lua")
require("/isl/lib/uicomponent.lua")
require("/isl/player/skill_points/skill_points.lua")

-- Constants ------------------------------------------------------------------
local Widgets = {}
Widgets.MotesCount = "motes_count_label"
Widgets.ProgressBarImage = "progress_bar_image"

-- Utility Functions ----------------------------------------------------------

function get_progress_frame(current_motes, from_motes, to_motes)
  -- Get the % of the next level
  if not from_motes or not to_motes then return ":done" end

  local current = current_motes - from_motes
  local target = to_motes - from_motes

  local percent_complete = (current / target)

  -- Cast to 0-9.5 in intervals of 0.5
  return ":"..math.floor((percent_complete * 10) / 0.5) * 0.5
end

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
   local collected_motes = ISLSkillPoints.get_skill_motes(player.id())
   local earned_skill_points =
     ISLSkillPoints.get_earned_skill_points(player.id())
   local motes_to_last_point = ISLSkillPoints.get_skill_motes_for_skill_point(
     earned_skill_points
   )
   local motes_to_next_point = ISLSkillPoints.get_skill_motes_for_skill_point(
     earned_skill_points + 1
   )

   -- Set the current currency # indicator
   widget.setText(
      self.layout_id..'.'..Widgets.MotesCount,
      collected_motes - motes_to_last_point
   )

   -- Set the progress bar
   local suffix = get_progress_frame(
     collected_motes,
     motes_to_last_point,
     motes_to_next_point
   )

   widget.setImage(
     self.layout_id..'.'..Widgets.ProgressBarImage,
     "/isl/constellation/assets/progress_bar.png"..suffix
   )
   widget.setVisible(
     self.layout_id..'.'..Widgets.ProgressBarImage,
     true
   )
end

function UIConstellationProgress:update()
  self:draw()
end

function UIConstellationProgress:createTooltip(position)
  if
    widget.inMember(self.layout_id..'.'..Widgets.ProgressBarImage, position)
  then
    local collected_motes = ISLSkillPoints.get_skill_motes(player.id())
    local earned_skill_points =
      ISLSkillPoints.get_earned_skill_points(player.id())
    local motes_to_last_point = ISLSkillPoints.get_skill_motes_for_skill_point(
      earned_skill_points
    )
    local motes_to_next_point = ISLSkillPoints.get_skill_motes_for_skill_point(
      earned_skill_points + 1
    )
    return string.format(
      "%d / %d motes required",
      collected_motes - motes_to_last_point,
      motes_to_next_point - motes_to_last_point
    )
  end
end
