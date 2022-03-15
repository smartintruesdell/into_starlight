--[[ Derived stat effects for the IntoStarlight Strength stat ]]
local diminishing_returns = require("/isl/lib/diminishing_returns.lua")

local STAT_NAME = "isl_strength"
local PATH = "/isl/player_stats/effects"

local function handler(entity_id, held_items)
  local config = root.assetJson(PATH.."/strength.config")
  local strength = world.callScriptedEntity(
    entity_id,
    "status.stat",
    STAT_NAME
  )
  local results = {}

  -- Melee weapon attack powerMultiplier bonus
  if stats.held_items.tags.contains("melee") then
    local raw_per_stat_point
    if held_items.tags.contains("twoHanded") then
      raw_per_stat_point = config.powerMultiplier.byTag.twoHanded or 0
    elseif held_items.tags.contains("dualWield") then
      raw_per_stat_point = config.powerMultiplier.byTag.dualWield or 0
    else
      raw_per_stat_point = config.powerMultiplier.byTag.oneHanded or 0
    end

    results["powerMultiplier"] = {
      amount = diminishing_returns(
        config.powerMultiplier.diminishingReturns.rate or 10,
        config.powerMultiplier.diminishingReturns.start or 0,
        config.powerMultiplier.diminishingReturns.factor or 0.1,
        strength * raw_per_stat_point
      )
    }
  end

  -- Shield shieldMaxHealth bonus
  if held_items.tags.contains("shield") then
    results["shieldMaxHealth"] = {
      amount = diminishing_returns(
        config.shieldMaxHealth.diminishingReturns.rate or 0,
        config.shieldMaxHealth.diminishingReturns.start or 0,
        config.shieldMaxHealth.diminishingReturns.factor or 0.0,
        strength * config.shieldMaxHealth.byTag.shield
      )
    }
  end

  return results
end

return handler
