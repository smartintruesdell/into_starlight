--[[
  This script defines the logic by which the player's stats from the IntoStarlight
  mod are applied to their damage/health/etc.
]]
require("/isl/player/stats/player_stats.lua")
require("/isl/player/stats/player_stats_controller.lua")
require("/isl/player/skill_points/skill_points_controller.lua")

function init()
  -- Change the status effect to only check for updates every 30 ticks, which
  -- is approximately half of a second
  script.setUpdateDelta(30)
  self.controllers = {}
  self.controllers.stat_effects = ISLPlayerStatEffectsController.new(entity.id())
  self.controllers.skill_points = ISLSkillPointController.new(entity.id())
end

function update(dt)
  for _, controller in pairs(self.controllers) do controller:update(dt) end
end
