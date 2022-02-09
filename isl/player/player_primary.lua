--[[
  This script modifies the way player events happen, and executes whenever the
  player is instantiated.
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")
require("/isl/stats/stats.lua")

-- Script `init`, `update`, and `uninit` will REPLACE scripts loaded before
-- ours. These `super_*` local variables save references to the scripts before
-- us so that we can call them at the start of our methods.
local no_op = function() end
local super_init = init or no_op
local super_update = update or no_op
local super_uninit = uninit or no_op
local super_applyDamageRequest = applyDamageRequest or no_op

function init()
  super_init()
end

--- Performs updates to the player effects
---
--- NOTE: This gets called every second, and can introduce substantial lag if
--- execution times start to run long. K3eep this simple, and try to avoid logging
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

--- global applyDamageRequest(DamageRequest) -> [DamageRequest]
---
--- Called on the Player when something tries to damage them.
function applyDamageRequest(damageRequest)
  -- Evasion provides a chance to DODGE attacks made against the player
  -- (it's a small chance with diminishing returns)
  local evasion = world.entityCurrency(entity.id(), "isl_evasion")
  if evasion > 0 then
    if math.random(100)<= ISLPlayerStats.get_evasion_dodge_chance(evasion) then
      -- TODO: Better particle emitter
      animator.burstParticleEmitter("outOfEnergy")
      return {}
    end
  end

  -- When we're done modifying the incoming damage request, we
  -- want to call the original `applyDamageRequest` method to
  -- ensure compatability with other mods that might be using
  -- it.
  return super_applyDamageRequest(damageRequest)
end
