--[[
  A utility class for modeling IntoStarlight stat effects
]]
require "/scripts/util.lua"
require "/scripts/questgen/util.lua"
require "/isl/lib/util.lua"
require "/isl/held_items/held_items.lua"

-- Constants ------------------------------------------------------------------

local PATH = "/isl/player_stats"

-- Class ----------------------------------------------------------------------

ISLPlayerStats = ISLPlayerStats or createClass("ISLPlayerStats")

-- Constructor ----------------------------------------------------------------

function ISLPlayerStats:init(entity_id)
  self.config = root.assetJson(PATH.."/player_stats.config")
  self.entity_id = entity_id

  self.held_items = nil

  self.persistent_effect_handlers = {}
  self.movement_effect_handlers = {}
  for stat_name, stat_data in pairs(self.config.stats) do
    self[stat_name] = stat_data.default or 0

    if stat_data.persistentEffectsHandler then
      self.persistent_effect_handlers[stat_name] =
        require(stat_data.persistentEffectsHandler)
    end

    if stat_data.movementEffectsHandler then
      self.movement_effect_handlers[stat_name] =
        require(stat_data.movementEffectsHandler)
    end
  end
end

-- Methods --------------------------------------------------------------------

---@param stat_name string The stat to update
---@param value number New stat value for the specified stat
function ISLPlayerStats:set_stat(stat_name, value)
  self[stat_name] = value or 0

  return self
end

function ISLPlayerStats:modify_stat(stat_name, dv)
  if dv ~= nil then
    self[stat_name] = self[stat_name] + dv
  end

  return self
end

function ISLPlayerStats:get_base_stat_persistent_effects()
  local results = {}
  for stat_name, _ in pairs(self.config.stats) do
    results[#results + 1] = {
      amount = self[stat_name]
    }
  end

  return results
end

local function merge_effects_map(left, right)
  for key, effect in pairs(right) do
    if not left[key] then
      left[key] = effect
    else
      left[key].amount = left[key].amount + right[key].amount
      left[key].baseMultiplier = left[key].baseMultiplier + right[key].baseMultiplier
      left[key].effectiveMultiplier =
        left[key].effectiveMultiplier + right[key].effectiveMultiplier
    end
  end
  return left
end

local function flatten_effects_map(effects_map)
  local results = {}
  for _, effect in pairs(effects_map) do
    results[#results+1] = effect
  end

  return results
end

function ISLPlayerStats:get_derived_stat_persistent_effects()
  local results_map = {}

  self.held_items =
    self.held_items or ISLHeldItems.new():read_from_entity(self.entity_id)

  for _, handler in pairs(self.persistent_effect_handlers) do
    results_map = merge_effects_map(
      results_map,
      handler(self.entity_id, self.held_items)
    )
  end

  return flatten_effects_map(results_map)
end

function ISLPlayerStats:get_derived_stat_movement_effects()
  local results_map = {}

  self.held_items =
    self.held_items or ISLHeldItems.new():read_from_entity(self.entity_id)

  for _, handler in pairs(self.movement_effect_handlers) do
    results_map = merge_effects_map(
      results_map,
      handler(self.entity_id, self.held_items)
    )
  end

  return flatten_effects_map(results_map)
end

-- TODO: Remove these before publishing

function ISLPlayerStats:read_from_entity()
  assert(false,"Deprecated call to `ISLPlayerStats:read_from_entity()`")
end

function ISLPlayerStats:read_from_player()
  assert(false, "Deprecated call to `ISLPlayerStats:read_from_player()`")
end

function ISLPlayerStats:apply_to_player()
  assert(false, "Deprecated call to `ISLPlayerStats:apply_to_player()`")
end

function ISLPlayerStats:get_stat()
  assert(false, "Deprecated call to `ISLPlayerStats:get_stat()`")
end

function ISLPlayerStats:get_evasion_dodge_chance()
  assert(false, "Deprecated call to `ISLPlayerStats:get_evasion_dodge_chance()`")
end

function ISLPlayerStats:get_critical_hit_chance()
  assert(false, "Deprecated call to `ISLPlayerStats:get_critical_hit_chance()`")
end

function ISLPlayerStats:get_critical_hit_multiplier()
  assert(false, "Deprecated call to `ISLPlayerStats:get_critical_hit_multiplier()`")
end

function ISLPlayerStats:get_attack_speed_multiplier()
  assert(false, "Deprecated call to `ISLPlayerStats:get_attack_speed_multiplier()`")
end

function ISLPlayerStats:get_cast_speed_multiplier()
  assert(false, "Deprecated call to `ISLPlayerStats:get_cast_speed_multiplier()`")
end

function ISLPlayerStats:get_charisma_price_reduction()
  assert(false, "Deprecated call to `ISLPlayerStats:get_charisma_price_reduction()`")
end
function ISLPlayerStats:get_charisma_sell_price_increase()
  assert(
    false,
    "Deprecated call to `ISLPlayerStats:get_charisma_sell_price_increase()`"
  )
end
