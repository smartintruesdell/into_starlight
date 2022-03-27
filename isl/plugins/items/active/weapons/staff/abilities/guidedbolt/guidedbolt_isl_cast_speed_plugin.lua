--[[ Adds cast speed from the player's stats to staff/wand effects ]]
require "/scripts/lpl_plugin_util.lua"

GuidedBolt.charge_get_initial_chargeTimer = Plugins.add_after_hook(
  GuidedBolt.charge_get_initial_chargeTimer,
  function (value)
    local cast_speed_multiplier = status.stat("isl_castSpeedMultiplier") or 1

    return value * cast_speed_multiplier
  end
)
