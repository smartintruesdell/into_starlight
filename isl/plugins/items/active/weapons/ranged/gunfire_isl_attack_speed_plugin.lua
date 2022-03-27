--[[ Adds attack-speed bonuses to MeleeSlash:cooldownTime method]]
require("/scripts/lpl_plugin_util.lua")

GunFire.get_cooldown_timer = Plugins.add_after_hook(
  GunFire.get_cooldown_timer,
  function(result)
    local attack_speed_multiplier = status.stat("isl_attack_speed_multiplier")

    return result * attack_speed_multiplier
  end
)

GunFire.get_stance_cooldown_duration = Plugins.add_after_hook(
  GunFire.get_stance_cooldown_duration,
  function(result)
    local attack_speed_multiplier = status.stat("isl_attack_speed_multiplier")

    return result * attack_speed_multiplier
  end
)
