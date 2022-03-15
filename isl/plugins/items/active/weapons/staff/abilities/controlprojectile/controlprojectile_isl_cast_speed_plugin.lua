--[[ Adds cast speed from the player's stats to staff/wand effects ]]
require "/scripts/lpl_plugin_util.lua"

ControlProjectile.charge_get_initial_chargeTimer = Plugins.add_after_hook(
  ControlProjectile.charge_get_initial_chargeTimer,
  function (value)
    local cast_speed_multiplier = status.stat("isl_cast_speed_multiplier")

    local new_cast_time = value * cast_speed_multiplier
    animator.setAnimationRate(1/cast_speed_multiplier)

    return new_cast_time
  end
)
