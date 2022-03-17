--[[
  Secondary stats display subcomponent for the Character Sheet

  Includes the stats that are not as sensitive to the player's choice
  of combat strategy
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/constants/strings.lua")
require("/isl/constellation/stats/stat_text.lua")
require("/isl/constellation/stats/stat_tooltip.lua")
require("/isl/lib/uicomponent.lua")
require("/isl/skillgraph/skillgraph.lua")

-- Class ----------------------------------------------------------------------

UIConstellationSecondaryStats =
  defineSubclass(UIComponent, "UIConstellationSecondaryStats")()

-- Constructor ----------------------------------------------------------------

function UIConstellationSecondaryStats:init(layout_id)
  ISLStrings.initialize()

  self.layout_id = layout_id

  self:addChild(
    "isl_vigor_text",
    UIConstellationStatText.new(
      "isl_vigor",
      true,
      layout_id,
      true
    )
  )
  self:addChild(
    "isl_mobility_text",
    UIConstellationStatText.new(
      "isl_mobility",
      true,
      layout_id,
      true
    )
  )
  self:addChild(
    "isl_charisma_text",
    UIConstellationStatText.new(
      "isl_charisma",
      true,
      layout_id,
      true
    )
  )
  self:addChild(
    "isl_celerity_text",
    UIConstellationStatText.new(
      "isl_celerity",
      true,
      layout_id,
      true
    )
  )
  self:addChild(
    "isl_savagery_text",
    UIConstellationStatText.new(
      "isl_savagery",
      true,
      layout_id,
      true
    )
  )
end

function UIConstellationSecondaryStats:createTooltip(mouse_position)
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
