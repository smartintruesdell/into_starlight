--[[
   A simple* struct and initializer for Stat configuration data
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Class ----------------------------------------------------------------------

ISLStats = ISLStats or createClass("Stats")

function ISLStats:init()
   local data = root.assetJson("/isl/stats/stats.config")

   for stat_name, stat_data in pairs(data) do
      -- save configuration from the json file
      self[stat_name] = stat_data
      self[stat_name].current = 0
   end
end

function ISLStats:set_stat(stat_name, new_value)
   new_value = new_value or self[stat_name].defaultValue
   new_bonus_value = new_bonus_value or self[stat_name].equipment_bonus or 0

   self[stat_name].current = new_value
   self[stat_name].bonus = new_bonus_value

   return self
end

function ISLStats:modify_stat(stat_name, dv, dbv)
   dv = dv or 0
   dbv = dbv or 0
   self[stat_name].current = (self[stat_name].current or 0) + dv
   self[stat_name].bonus = (self[stat_name].bonus or 0) + dbv

   return self
end

function ISLStats:read_from_player()
   for stat_name, _ in pairs(self) do
      self[stat_name].current = player.getProperty(stat_name)
   end
end

function ISLStats:save_to_player()
   for stat_name, stat_data in pairs(self) do
      player.setProperty(stat_name, stat_data.current)
   end
end

function ISLStats:reset_stat(stat_name)
   self[stat_name].current = self[stat_name].defaultValue
   self[stat_name].bonus = 0
   player.setProperty(stat_name, self[stat_name].defaultValue)
end

function ISLStats:reset_stats()
   for stat_name, _ in pairs(self) do
      self:reset_stat(stat_name)
   end
end

function ISLStats:debug()
   ISLLog.debug(self:toString())
end
