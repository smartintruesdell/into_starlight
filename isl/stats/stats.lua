--[[
   A simple* struct and initializer for Stat configuration data
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Class ----------------------------------------------------------------------

ISLPlayerStats = ISLPlayerStats or createClass("Stats")

function ISLPlayerStats:init(entity_id)
   self.entity_id = entity_id
   if player and not entity_id then
      self.entity_id = player.id()
   end

   local data = root.assetJson("/isl/stats/stats.config")

   for stat_name, stat_data in pairs(data) do
      -- save configuration from the json file
      self[stat_name] = stat_data
      self[stat_name].current = 0
   end
end

function ISLPlayerStats:set_stat(stat_name, new_value)
   new_value = new_value or self[stat_name].defaultValue

   self[stat_name].current = new_value

   return self
end

function ISLPlayerStats:modify_stat(stat_name, dv)
   dv = dv or 0
   self[stat_name].current = (self[stat_name].current or 0) + dv

   return self
end

function ISLPlayerStats:update(_dt)
   local changed = false

   for stat_name, _ in pairs(self) do
      local new_value = world.entityCurrency(self.entity_id, stat_name)
      if self[stat_name].current ~= new_value then
         changed = true
         self[stat_name].current = new_value
      end
   end
   return changed
end

function ISLPlayerStats:save()
   assert(
      player ~= nil,
      "Tried to save stats in a context where the `player` object was unavailable"
   )
   for stat_name, stat_data in pairs(self) do
      local last = player.currency(stat_name)
      local ds = stat_data.current - last
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
   for stat_name, _ in pairs(self) do
      self:reset_stat(stat_name)
   end

   return self
end
