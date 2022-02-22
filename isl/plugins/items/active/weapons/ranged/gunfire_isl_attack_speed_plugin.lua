--[[ Adds attack-speed bonuses to MeleeSlash:cooldownTime method]]
require("/scripts/lpl_plugin_util.lua")
require("/isl/player/stats/player_stats.lua")

GunFire.get_cooldown_timer = Plugins.add_after_hook(
  GunFire.get_cooldown_timer,
  function(result)
    local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())

    local attack_speed_multiplier = player_stats.get_attack_speed_multiplier()

    return result * attack_speed_multiplier
  end
)

GunFire.get_stance_cooldown_duration = Plugins.add_after_hook(
  GunFire.get_stance_cooldown_duration,
  function(result)
    local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())

    local attack_speed_multiplier = player_stats.get_attack_speed_multiplier()

    return result * attack_speed_multiplier
  end
)
