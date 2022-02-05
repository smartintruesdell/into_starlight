--[[
   This script defines the logic by which the player's stats from the IntoStarlight
   mod are applied to their damage/health/etc.
]]
require("/isl/stats/stats.lua")
require("/isl/stats/stat_effects.lua")

function init()
   -- Change the status effect to only check for updates every 30 ticks, which
   -- is approximately half of a second
   script.setUpdateDelta(30)
   self.effect = ISLStatEffects.new(entity.id())
end

function update(dt)
   self.effect:update(dt)
end