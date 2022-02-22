--[[ Adds attack-speed bonuses to MeleeSlash:cooldownTime method]]
require("/scripts/lpl_plugin_util.lua")
require("/isl/player/stats/player_stats.lua")

MeleeSlash.cooldownTime = Plugins.add_after_hook(
  MeleeSlash.cooldownTime,
  function(result)
    local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())

    local attack_speed_multiplier = player_stats.get_attack_speed_multiplier()

    return result * attack_speed_multiplier
  end
)
