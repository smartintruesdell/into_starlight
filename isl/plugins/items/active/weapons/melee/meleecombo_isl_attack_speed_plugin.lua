--[[ Adds attack-speed bonuses to MeleeSlash:cooldownTime method]]
require("/scripts/lpl_plugin_util.lua")

local function apply_attack_speed_multiplier(value)
  local attack_speed_multiplier = status.stat("isl_attack_speed_multiplier")

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
