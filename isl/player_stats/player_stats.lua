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

function ISLPlayerStats:init(entity_id)
  self.changed = true
  self.entity_id = entity_id
  if player and not entity_id then
    self.entity_id = player.id()
  end

  Config = Config or root.assetJson("/isl/stats/stats.config")

  for stat_name, stat_data in pairs(Config) do
    -- save configuration from the json file
    self[stat_name] = stat_data
    self[stat_name].amount = 0
    self[stat_name].multiplier = 1
  end
end

---@param stat_name string The stat to update
---@param new_values table New stat values for that stat
function ISLPlayerStats:set_stat(stat_name, new_values)
  self.changed = true
  new_values = new_values or {}
  new_values.amount = new_values.amount or self[stat_name].amount or 0
  new_values.multiplier = new_values.multiplier or self[stat_name].multiplier or 1

  self[stat_name] = new_values

  return self
end

function ISLPlayerStats:modify_stat(stat_name, delta)
  self.changed = true
  delta = delta or {}
  delta.amount = delta.amount or 0
  delta.multiplier = delta.multipler or 1
  self[stat_name].amount = self[stat_name].amount + delta.amount
  self[stat_name].multiplier = self[stat_name].multiplier + (delta.multiplier - 1)

  return self
end

function ISLPlayerStats:update(_dt)
  assert(self ~= nil, "Remember to use ISLPlayerStats:update instead of ISLPlayerStats.update")

  for stat_name, _ in pairs(Config) do
    assert(self[stat_name] ~= nil, "Found a nil stat "..stat_name)

    local new_amount = world.entityCurrency(self.entity_id, stat_name)
    local new_multiplier = world.entityCurrency(
      self.entity_id,
      stat_name.."_multiplier"
    )
    -- EARLY OUT HERE
    -- If we call the update method during player_init, the first invocation
    -- will take place before the player is fully initialized and we want to
    -- essentially allow it to fail once.
    if new_amount == nil then return false end

    local new_values = {
      amount = new_amount,
      multiplier = ISLUtil.round_to_digits(2, new_multiplier / 100)
    }

    if
      self[stat_name].amount ~= new_values.amount or
      self[stat_name].multiplier ~= new_values.multiplier
    then
      ISLLog.debug(
        "caught a change to the %s currencies, updating the stat: %s -> %s",
        stat_name,
        util.tableToString(self[stat_name]),
        util.tableToString(new_values)
      )
      self:set_stat(stat_name, new_values)
    end
  end
  return changed
end

function ISLPlayerStats:save()
  assert(
    player ~= nil,
    "Tried to save stats in a context where the `player` object was unavailable"
  )
  for stat_name, _ in pairs(Config) do
    local last_amount = player.currency(stat_name)
    local last_multiplier = player.currency(stat_name.."_multiplier")

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

function ISLPlayerStats:reset_stat(stat_name)
  self[stat_name].amount = self[stat_name].defaultValue
  self[stat_name].multiplier = 1

  return self
end

function ISLPlayerStats:reset_stats()
  for stat_name, _ in pairs(Config) do
    self:reset_stat(stat_name)
  end

  return self
end

function ISLPlayerStats.hard_reset(player)
  Config = Config or root.assetJson("/isl/stats/stats.config")
  assert(player ~= nil, "Tried to hard_reset without a valid player reference")
  ISLLog.debug("ISLPlayerStats.hard_reset(%s)", player.id())

  for stat_name, stat_config in pairs(Config) do
    local last_amount = player.currency(stat_name)
    local last_multiplier = player.currency(stat_name.."_multiplier")

    local delta_amount = last_amount - stat_config.defaultValue
    local delta_multiplier = last_multiplier - 100

    if delta_amount > 0 then
      player.consumeCurrency(stat_name, delta_amount)
    elseif delta_amount < 0 then
      player.addCurrency(stat_name, math.abs(delta_amount))
    end

    if delta_multiplier > 0 then
      player.consumeCurrency(stat_name.."_multiplier", delta_multiplier)
    elseif delta_multiplier < 0 then
      player.addCurrency(stat_name.."_multiplier", math.abs(delta_multiplier))
    end
  end
end

function ISLPlayerStats.get_evasion_dodge_chance(evasion)
  return 35 * math.log(evasion * 0.025) + 0.2
end
