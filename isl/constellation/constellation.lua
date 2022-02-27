--[[
  Interface logic for the IntoStarlight Skilltree
  Based in part on the Frackin' Universe researchTree
]]
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/point.lua")
require("/isl/constants/strings.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/lib/uicomponent.lua")
require("/isl/constellation/skilltree/skilltree.lua")
require("/isl/constellation/header/header.lua")
require("/isl/constellation/perks/perks.lua")
require("/isl/constellation/progress/progress.lua")
require("/isl/constellation/stats/stats.lua")

-- Class --------------------------------------------------------------------

UIConstellation = defineSubclass(UIComponent, "UIConstellation")()

-- Constructor ----------------------------------------------------------------

function UIConstellation:init()
  UIComponent.init(self) -- super()

  -- Info Panel Components
  self:addChild("header", UIConstellationHeader.new("headerLayout"))
  self:addChild(
    "primaryStats",
    UIConstellationStats.new("primaryStatsLayout")
  )
  -- self:addChild("secondaryStats", UIConstellationSecondaryStats.new(""))
  self:addChild("perks", UIConstellationPerks.new("perksScrollArea.perksList"))
  self:addChild("progress", UIConstellationProgress.new("progressLayout"))

  -- Skill Tree Components
  self:addChild("skill_tree", UISkillTree.new("canvas"))
end

-- Event Handlers -------------------------------------------------------------

function handle_canvas_mouse_event(...)
  self.Constellation:handleMouseEvent(...)
end

function closeButton()
  pane.dismiss()
end

function handle_revert_button()
  ISLSkillGraph.revert()
  self.Constellation:draw()
end

function handle_apply_button()
  SkillGraph:apply_to_player(player)
  self.Constellation:draw()
end

function handle_respec_button()
  ISLSkillGraph.reset_unlocked_skills(player)

  self.Constellation:draw()
end

function no_op() end

-- Init -----------------------------------------------------------------------

function init()
  -- Initialize UI components
  if not SkillGraph then ISLSkillGraph.initialize() end
  if not Strings then ISLStrings.initialize() end

  self.Constellation = UIConstellation.new()

  -- Draw
  self.Constellation:draw()
end

function update(dt)
  self.Constellation:update(dt)
end

function createTooltip(mouse_position)
  return self.Constellation:createTooltip(Point.new(mouse_position))
end
