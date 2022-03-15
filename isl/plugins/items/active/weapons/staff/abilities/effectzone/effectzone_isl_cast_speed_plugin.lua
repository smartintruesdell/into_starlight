--[[ Adds cast speed from the player's stats to staff/wand effects ]]
require "/scripts/lpl_plugin_util.lua"

EffectZone.charge_get_initial_chargeTimer = Plugins.add_after_hook(
  EffectZone.charge_get_initial_chargeTimer,
  function (value)
    local cast_speed_multiplier = status.stat("isl_cast_speed_multiplier")

    return value * cast_speed_multiplier
  end
)
