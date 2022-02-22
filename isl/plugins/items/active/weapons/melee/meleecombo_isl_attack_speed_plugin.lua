--[[ Adds attack-speed bonuses to MeleeSlash:cooldownTime method]]
require("/scripts/lpl_plugin_util.lua")
require("/isl/player/stats/player_stats.lua")

local function apply_attack_speed_multiplier(value)
  local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())

  local attack_speed_multiplier = player_stats.get_attack_speed_multiplier()

  return value * attack_speed_multiplier
end

MeleeCombo.get_step_cooldown = Plugins.add_after_hook(
  MeleeCombo.get_step_cooldown,
  apply_attack_speed_multiplier
)

MeleeCombo.get_stance_duration = Plugins.add_after_hook(
  MeleeCombo.get_stance_duration,
  apply_attack_speed_multiplier
)
