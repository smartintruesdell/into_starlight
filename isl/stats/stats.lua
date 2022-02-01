--[[
   A simple struct and initializer for Stat configuration data
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
   end

   self:update()
end

function ISLStats:update(_ --[[dt: number]])
   for stat_name, stat_data in pairs(self) do
      self[stat_name].current = player.getProperty(stat_name) or stat_data.defaultValue
   end
end

function ISLStats:save_to_player()
   for stat_id, stat_data in pairs(self.stats) do
      player.setProperty(stat_id, stat_data.current)
   end
end
