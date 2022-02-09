--[[
   This script is called when the player is spawned into the world, and
   sets up the components of IntoStarlight that impact Player stats/equipment/etc.
]]
require("/isl/lib/log.lua")

-- Script `init`, `update`, and `uninit` will REPLACE scripts loaded before
-- ours. These `super_*` local variables save references to the scripts before
-- us so that we can call them at the start of our methods.
local super_init = init or function () end
local super_update = update or function () end
local super_uninit = uninit or function () end

function init()
   super_init()
end

--- Performs updates to the player effects
---
--- NOTE: This gets called every second, and can introduce substantial lag if
--- execution times start to run long. Keep this simple, and try to avoid logging
--- (disk I/O can be slow)
function update(dt)
   super_update(dt)

   -- Every Tick, we're going to make sure that the player has a live instance
   -- of the status effect that applies ISL stats to the player.
   status.addEphemeralEffect("isl_main_effect", math.huge)
end

function uninit()
   super_uninit()
end
