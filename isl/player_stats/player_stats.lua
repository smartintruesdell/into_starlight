--[[
  A simple* struct and initializer for Stat configuration data
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/util.lua")

-- Constants ------------------------------------------------------------------

local Config = nil

-- Class ----------------------------------------------------------------------

ISLPlayerStats = ISLPlayerStats or createClass("ISLPlayerStats")

-- Constructor ----------------------------------------------------------------

function ISLPlayerStats:init()
  Config = Config or root.assetJson("/isl/player_stats/player_stats.config")

  for stat_name, stat_data in pairs(Config) do
    -- save configuration from the json file
    self[stat_name] = stat_data
    self[stat_name].amount = stat_data.defaultAmount or 0
    self[stat_name].multiplier = stat_data.defaultMultiplier or 1
  end
end

-- Static Methods -------------------------------------------------------------

--- An abstraction over applying a blank stats object to the player
function ISLPlayerStats.hard_reset(player)
  return ISLPlayerStats.new():apply_to_player(player)
end

-- TODO: Make this an instance method, this is silly.
function ISLPlayerStats:get_evasion_dodge_chance()
  local evasion = (self.isl_evasion.amount or 0) * (self.isl_evasion.multiplier or 1)
  return 35 * math.log(evasion * 0.025) + 0.2
end

-- Methods --------------------------------------------------------------------

---@param stat_name string The stat to update
---@param new_values table New stat values for that stat
function ISLPlayerStats:set_stat(stat_name, new_values)
  new_values = new_values or {}
  new_values.amount = new_values.amount or self[stat_name].amount or 0
  new_values.multiplier = new_values.multiplier or self[stat_name].multiplier or 1

  self[stat_name] = new_values

  return self
end

function ISLPlayerStats:modify_stat(stat_name, delta)
  delta = delta or {}
  delta.amount = delta.amount or 0
  delta.multiplier = delta.multipler or 1
  self[stat_name].amount = self[stat_name].amount + delta.amount
  self[stat_name].multiplier = self[stat_name].multiplier + (delta.multiplier - 1)

  return self
end

function ISLPlayerStats:read_from_entity(entity_id)
  assert(self ~= nil, "Remember to use ISLPlayerStats:read_from_entity instead of ISLPlayerStats.read_from_entity")
  local changed = false

  for stat_name, _ in pairs(Config) do
    local new_amount = world.entityCurrency(entity_id, stat_name)
    local new_multiplier = world.entityCurrency(
      entity_id,
      stat_name.."_multiplier"
    )
    -- EARLY OUT HERE
    -- If we call the update method during player_init, the first invocation
    -- will take place before the player is fully initialized and we want to
    -- essentially allow it to fail once.
    if new_amount == nil then return self, false end

    local new_values = {
      amount = new_amount,
      multiplier = ISLUtil.round_to_digits(2, new_multiplier / 100)
    }

    if
      self[stat_name].amount ~= new_values.amount or
      self[stat_name].multiplier ~= new_values.multiplier
    then
      changed = true
      self:set_stat(stat_name, new_values)
    end
  end

  return self, changed
end

function ISLPlayerStats:read_from_player(player)
  assert(self ~= nil, "Remember to use ISLPlayerStats:read_from_player instead of ISLPlayerStats.read_from_player")
  assert(player ~= nil and type(player) == "table", "Expected a valid `player`")
  local changed = false

  for stat_name, _ in pairs(Config) do
    local new_amount = player.currency(stat_name)
    local new_multiplier = player.currency(stat_name.."_multiplier")

    local new_values = {
      amount = new_amount,
      multiplier = ISLUtil.round_to_digits(2, new_multiplier / 100)
    }

    if
      self[stat_name].amount ~= new_values.amount or
      self[stat_name].multiplier ~= new_values.multiplier
    then
      changed = true
      self:set_stat(stat_name, new_values)
    end
  end

  return self, changed
end

function ISLPlayerStats:apply_to_player(player)
  assert(
    player ~= nil,
    "Tried to save stats in a context where the `player` object was unavailable"
  )
  local get_currency =
    player.currency or
    function (stat_name)
      return world.entityCurrency(player.id(), stat_name)
    end

  for stat_name, _ in pairs(Config) do
    local last_amount = get_currency(stat_name)
    local last_multiplier = get_currency(stat_name.."_multiplier")

    local delta_amount = self[stat_name].amount - last_amount
    local delta_multiplier = (self[stat_name].multiplier * 100) - last_multiplier

    if delta_amount > 0 then
      player.addCurrency(stat_name, delta_amount)
    elseif delta_amount < 0 then
      player.consumeCurrency(stat_name, math.abs(delta_amount))
    end
    if delta_multiplier > 0 then
      player.addCurrency(stat_name.."_multiplier", delta_multiplier)
    elseif delta_multiplier < 0 then
      player.consumeCurrency(stat_name.."_multiplier", math.abs(delta_multiplier))
    end
  end

  return self
end
