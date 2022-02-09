--[[
  Models StatusEffects in a simple map and allows for easy conversion to a
  vector of individual effects
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

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
    if effect.amount then
      table.insert(
        results,
        { stat = key, amount = effect.amount }
      )
    end
    if effect.baseMultiplier then
      table.insert(
        results,
        { stat = key, baseMultiplier = effect.baseMultiplier }
      )
    end
    if effect.effectiveMultiplier then
      table.insert(
        results,
        { stat = key, effectiveMultiplier = effect.effectiveMultiplier }
      )
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
      (self[key].baseMultiplier or 0) + (effect.baseMultiplier or 0)
    self[key].effectiveMultiplier =
      (self[key].effectiveMultiplier or 0) + (effect.effectiveMultiplier or 0)
  end

  return self
end
