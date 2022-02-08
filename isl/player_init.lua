--[[
   This script is called when the player is spawned into the world, and
   sets up the components of IntoStarlight that impact Player stats/equipment/etc.
]]
require("/isl/lib/log.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/stats/stats.lua")

-- Script `init`, `update`, and `uninit` will REPLACE scripts loaded before
-- ours. These `super_*` local variables save references to the scripts before
-- us so that we can call them at the start of our methods.
local super_init = init
local super_update = update
local super_uninit = uninit

-- Player Initialization ------------------------------------------------------
function init()
   super_init()
   ISLLog.info("Initializing IntoStarlight Player Features")
   ISLPlayerStats.hard_reset(player);
   local graph = ISLSkillGraph.initialize(LOG_LEVEL == LOG_LEVELS.DEBUG)

   graph:apply_to_player()
end

-- Player Update --------------------------------------------------------------
function update(dt)
   super_update(dt)
end

-- Player Destruction ---------------------------------------------------------
function uninit()
   super_uninit()
   ISLLog.info("Cleaning up IntoStarlight Player Features")
end
