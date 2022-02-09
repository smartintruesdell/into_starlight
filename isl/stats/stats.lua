--[[
   A simple* struct and initializer for Stat configuration data
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Constants ------------------------------------------------------------------

local Config = nil

-- Class ----------------------------------------------------------------------

ISLPlayerStats = ISLPlayerStats or createClass("ISLPlayerStats")

function ISLPlayerStats:init(entity_id)
   self.entity_id = entity_id
   if player and not entity_id then
      self.entity_id = player.id()
   end

   Config = Config or root.assetJson("/isl/stats/stats.config")

   for stat_name, stat_data in pairs(Config) do
      -- save configuration from the json file
      self[stat_name] = stat_data
      self[stat_name].current = 0
   end
end

function ISLPlayerStats:set_stat(stat_name, new_value)
   next = new_value
   assert(next ~= nil, "Tried to set "..stat_name.." to nil")
   self[stat_name].current = next

   return self
end

function ISLPlayerStats:modify_stat(stat_name, dv)
   dv = dv or 0
   local next = (self[stat_name].current or 0) + dv

   return self:set_stat(stat_name, next)
end

function ISLPlayerStats:update(_dt)
   local changed = false

   for stat_name, _ in pairs(Config) do
      local next = world.entityCurrency(self.entity_id, stat_name) or 0
      assert(self[stat_name] ~= nil, "Found a nil stat "..stat_name)

      if self[stat_name].current ~= next then
         changed = true
         self:set_stat(stat_name, next)
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
      local last = player.currency(stat_name)
      assert(self[stat_name] ~= nil, "Found a nil stat "..stat_name)
      assert(self[stat_name].current ~= nil, "Found a nil stat "..stat_name)
      local ds = self[stat_name].current - last
      if ds > 0 then
         player.addCurrency(stat_name, ds)
      elseif ds < 0 then
         player.consumeCurrency(stat_name, ds)
      end
   end
end

function ISLPlayerStats:reset_stat(stat_name)
   self[stat_name].current = self[stat_name].defaultValue

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

   for stat_name, stat_data in pairs(Config) do
      local last = player.currency(stat_name)
      local ds = last - stat_data.defaultValue
      if ds > 0 then
         player.consumeCurrency(stat_name, ds) -- reset to default
      elseif ds < 0 then
         player.addCurrency(stat_name, math.abs(ds))
      end
   end
end

function ISLPlayerStats.get_evasion_dodge_chance(evasion)
  return 35 * math.log(evasion * 0.025) + 0.2
end
