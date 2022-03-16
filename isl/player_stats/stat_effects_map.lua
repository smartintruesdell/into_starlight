--[[
  Models StatusEffects in a simple map and allows for easy conversion to a
  vector of individual effects
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")

require "/isl/player_stats/stat_effect.lua"

-- Classes ----------------------------------------------------------------------

ISLStatEffectsMap = ISLStatEffectsMap or createClass("ISLStatEffectsMap")

-- Constructor ----------------------------------------------------------------

function ISLStatEffectsMap:init(defaults)
  for key, value in pairs(defaults or {}) do
    self[key] = ISLStatEffect.new(value)
  end
end

-- Methods --------------------------------------------------------------------

--- Destructures the map into a Vec of individual persistent effects
function ISLStatEffectsMap:spread()
  local results = {}
  for _, effect in pairs(self) do
    results[#results + 1] = effect:to_persistent_effect()
  end

  return results
end

local MCONTROLLER_EFFECTS = StringSet.new({
  "airJumpModifier",
  "airJumpPower",
  "speedModifier"
})
local MCONTROLLER_EFFECT_OFFSETS = {
  airJumpModifier = 1,
  airJumpPower = 1,
  speedModifier = 1
}
function ISLStatEffectsMap:get_persistent_StatEffects()
  return util.filter(
    self:spread(),
    function (effect)
      return not MCONTROLLER_EFFECTS:contains(effect.stat)
    end
  )
end
function ISLStatEffectsMap:get_ActorMovementModifiers()
  local results = {}
  for _, key in ipairs(MCONTROLLER_EFFECTS:to_Vec()) do
    if self[key] then
      results[key] = self[key]:to_mcontroller_effect(MCONTROLLER_EFFECT_OFFSETS[key])
    end
  end
  return results
end

--- Applies addition of an amount to the amount of a specified keyed stat
function ISLStatEffectsMap:adjust_amount(key, dv)
  self[key] =
    (self[key] or ISLStatEffect.new({ stat = key })):adjust_amount(dv)

  return self
end
--- Applies addition of a baseMultiplier to the baseMultiplier of a specified
--- keyed stat
function ISLStatEffectsMap:adjust_baseMultiplier(key, dv)
  self[key] =
    (self[key] or ISLStatEffect.new({ stat = key })):adjust_baseMultiplier(dv)

  return self
end
--- Applies addition of a effectiveMultiplier to the effectiveMultiplier of a
--- specified keyed stat
function ISLStatEffectsMap:adjust_effectiveMultiplier(key, dv)
  self[key] =
    (self[key] or ISLStatEffect.new({ stat = key })):adjust_effectiveMultiplier(dv)

  return self
end

--- Applies a change to a specific effect on the map
function ISLStatEffectsMap:apply(key, fn)
  self[key] = fn(self[key])

  return self
end

function ISLStatEffectsMap:concat(other_map)
  for key, effect in pairs(other_map) do
    self[key] =
      ((self[key] or ISLStatEffect.new({ stat = key })):concat(effect))
  end

  return self
end
