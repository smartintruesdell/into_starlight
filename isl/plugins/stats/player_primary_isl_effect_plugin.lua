--[[ Add a hook to Player:update to enforce the primary stats effect]]

-- Constants ------------------------------------------------------------------

local EFFECTS = {}
EFFECTS.CONTROLLER = "isl_player_controllers"

--- Performs updates to the player effects
---
--- NOTE: This gets called every second, and can introduce substantial lag if
--- execution times start to run long. K3eep this simple, and try to avoid logging
--- (disk I/O can be slow)
local super_update = update
update = function (dt)
  -- Every Tick, we're going to make sure that the player has a live instance
  -- of the status effect that applies ISL stats to the player.
  super_update(dt)
  status.addEphemeralEffect(EFFECTS.CONTROLLER, math.huge)
end
