--[[
  Stats display subcomponent for the Character Sheet
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/constants/strings.lua")
require("/isl/lib/bounds.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/player/stats/player_stats.lua")
require("/isl/lib/uicomponent.lua")
require("/isl/constellation/portrait/portrait.lua")
require("/isl/constellation/stats/stat_text.lua")

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
        local tooltip = config.getParameter("tooltipLayouts.stat")
        local title = Strings:getString(child.tooltipTitleStringId)
        tooltip.description.value =
          Strings:getString(child.tooltipDescriptionStringId)

        tooltip.title.value = title

        local cases = {
          strengthButton = {
            stat = "isl_strength",
            color = Colors.get_color("melee")
          },
          precisionButton = {
            stat = "isl_precision",
            color = Colors.get_color("ranged")
          },
          witsButton = {
            stat = "isl_wits",
            color = Colors.get_color("magical")
          },
          defenseButton = {
            stat = "isl_defense",
            color = Colors.get_color("melee")
          },
          evasionButton = {
            stat = "isl_evasion",
            color = Colors.get_color("ranged")
          },
          focusButton = {
            stat = "isl_focus",
            color = Colors.get_color("magical")
          }
        }
        if cases[child_id] ~= nil then
          local color = "^"..cases[child_id].color..";"
          local reset = "^reset;"
          local details = SkillGraph:get_stat_details(cases[child_id].stat)

          tooltip.details.value = string.format(
            Strings:getString("stats_details"),
            color..details.from_species..reset,
            player.species(),
            color..details.from_skills..reset,
            color..details.from_perks..reset
          )
        end

        return tooltip
      end
    end
  end

  self:createTooltipsForChildren(mouse_position)
end
