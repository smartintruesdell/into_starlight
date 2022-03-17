--[[ Adds attack-speed bonuses to MeleeSlash:cooldownTime method]]
require "/scripts/lpl_plugin_util.lua"

MeleeSlash.cooldownTime = Plugins.add_after_hook(
  MeleeSlash.cooldownTime,
  function(result)
    local attack_speed_multiplier = status.stat("isl_attackSpeedMultiplier") or 1

    return result * attack_speed_multiplier
  end
)
