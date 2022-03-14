--[[
  Models StatusEffects in a simple map and allows for easy conversion to a
  vector of individual effects
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")

-- Class ----------------------------------------------------------------------

ISLEffectsMap = ISLEffectsMap or createClass("ISLEffectsMap")

-- Constructor ----------------------------------------------------------------

function ISLEffectsMap:init(defaults)
  defaults = defaults or {}
  for key, value in pairs(defaults) do
    self[key] = value
  end
end

-- Methods --------------------------------------------------------------------

--- Destructures the map into a Vec of individual persistent effects
function ISLEffectsMap:spread()
  local results = {}
  for key, effect in pairs(self) do
    if effect.amount ~= 0 then
      table.insert(
        results,
        { stat = key, amount = effect.amount }
      )
    end
    if effect.baseMultiplier ~= 1 then
      table.insert(
        results,
        { stat = key, baseMultiplier = effect.baseMultiplier }
      )
    end
    if effect.effectiveMultiplier ~= 1 then
      table.insert(
        results,
        { stat = key, effectiveMultiplier = effect.effectiveMultiplier }
      )
    end
  end

  return results
end

local MControllerEffects = StringSet.new({ "airJumpModifier", "speedModifier" })
local MControllerEffectOffsets = {
  airJumpModifier = 1,
  speedModifier = 1
}
function ISLEffectsMap:spread_persistent()
  return util.filter(
    self:spread(),
    function (effect)
      return not MControllerEffects:contains(effect.stat)
    end
  )
end
function ISLEffectsMap:spread_mcontroller()
  local results = {}
  for _, key in ipairs(MControllerEffects:to_Vec()) do
    if self[key] then
      results[key] = (MControllerEffectOffsets[key] + (self[key].amount or 0)) *
        (self[key].baseMultiplier or 1) *
        (self[key].effectiveMultiplier or 1)
    end
  end
  return results
end

--- Applies a change to a specific effect on the map
function ISLEffectsMap:apply(key, fn)
  self[key] = fn(self[key])

  return self
end

function ISLEffectsMap:concat(other_map)
  for key, effect in pairs(other_map) do
    if not self[key] then self[key] = {} end
    self[key].amount = (self[key].amount or 0) + (effect.amount or 0)
    self[key].baseMultiplier =
      (self[key].baseMultiplier or 1) + ((effect.baseMultiplier or 1) - 1)
    self[key].effectiveMultiplier =
      (self[key].effectiveMultiplier or 1) + ((effect.effectiveMultiplier or 1) - 1)
  end

  return self
end
