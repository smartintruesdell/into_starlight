--[[ Add a hook to Player:applyDamageRequest to support dodging ]]
require("/scripts/lpl_plugin_util.lua")
require("/isl/player/stats/player_stats.lua")
require("/isl/lib/log.lua")

-- Constants ------------------------------------------------------------------

local DODGE_EFFECT = "isl_dodge_particle"

--- global applyDamageRequest(DamageRequest) -> [DamageRequest]
---
--- Called on the Player when something tries to damage them.
applyDamageRequest_player_is_invulnerable = Plugins.add_after_hook(
  applyDamageRequest_player_is_invulnerable,
  function(...)
    -- Because applyDamageRequest_player_is_invulnerable returns NIL, it
    -- doesn't get passed into our hook all the time. This can result
    -- in some weirdness when trying to detect a TRUE return.
    local arg0 = select(1, ...)
    if type(arg0) == "boolean"  and arg0 then
      return true
    end

    local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())

    -- Evasion provides a chance to DODGE attacks made against the player
    -- (it's a small chance with diminishing returns)
    local dodge_chance = player_stats:get_evasion_dodge_chance()
    local roll = math.random(100)
    if dodge_chance > 0 and roll <= dodge_chance then
      ISLLog.debug("Dodge! %f:%f", dodge_chance, roll)
      status.addEphemeralEffect(DODGE_EFFECT) -- "Dodge!" particle
      return true
    end

    return false
  end
)
