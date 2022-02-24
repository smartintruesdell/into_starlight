--[[ Adds cast speed from the player's stats to staff/wand effects ]]
require "/scripts/lpl_plugin_util.lua"

GuidedBolt.charge_get_initial_chargeTimer = Plugins.add_after_hook(
  GuidedBolt.charge_get_initial_chargeTimer,
  function (value)
    local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())

    local cast_speed_multiplier = player_stats.get_cast_speed_multiplier()

    return value * cast_speed_multiplier
  end
)
