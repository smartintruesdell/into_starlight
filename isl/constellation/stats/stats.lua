--[[
  Stats display subcomponent for the Character Sheet
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/constants/strings.lua")
require("/isl/constellation/portrait/portrait.lua")
require("/isl/constellation/stats/stat_text.lua")
require("/isl/constellation/stats/stat_tooltip.lua")
require("/isl/lib/uicomponent.lua")
require("/isl/player_stats/player_stats.lua")
require("/isl/skillgraph/skillgraph.lua")

-- Class ----------------------------------------------------------------------

UIConstellationStats = defineSubclass(UIComponent, "UIConstellationStats")()

-- Constructor ----------------------------------------------------------------

function UIConstellationStats:init(layout_id)
  if not Strings then ISLStrings.initialize() end

  self.layout_id = layout_id
  self:addChild("portrait", UIPortrait.new(layout_id..".portrait", "full"))
  self:addChild(
    "isl_strength_text",
    UIConstellationStatText.new(
      "isl_strength",
      true,
      layout_id
    )
  )
  self:addChild(
    "isl_precision_text",
    UIConstellationStatText.new(
      "isl_precision",
      true,
      layout_id
    )
  )
  self:addChild(
    "isl_wits_text",
    UIConstellationStatText.new(
      "isl_wits",
      true,
      layout_id
    )
  )
  self:addChild(
    "isl_defense_text",
    UIConstellationStatText.new(
      "isl_defense",
      false,
      layout_id
    )
  )
  self:addChild(
    "isl_evasion_text",
    UIConstellationStatText.new(
      "isl_evasion",
      false,
      layout_id
    )
  )
  self:addChild(
    "isl_focus_text",
    UIConstellationStatText.new(
      "isl_focus",
      false,
      layout_id
    )
  )
end

function UIConstellationStats:createTooltip(mouse_position)
  if (widget.inMember(self.layout_id, mouse_position)) then
    for child_id, child in pairs(
      config.getParameter("gui."..self.layout_id..".children")
    ) do
      if
        child.tooltipTitleStringId and
        widget.inMember(self.layout_id.."."..child_id, mouse_position)
      then
        return create_stat_tooltip(
          child_id,
          child.tooltipTitleStringId,
          child.tooltipDescriptionStringId
        )
      end
    end
  end

  self:createTooltipsForChildren(mouse_position)
end
