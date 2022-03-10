--[[
  A plugin for bossMonster.lua to encourage bosses to spawn experience when they die
]]
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/lpl_plugin_util.lua"

local PATH = "/monsters/boss/"

local function get_config_parameter(config, key, default)
  if config[key] == nil then return default end
  return config[key]
end

update_handle_death = Plugins.add_after_hook(
  update_handle_death,
  function ()
    -- Read the config for the burst
    local config = root.assetJson(PATH.."/mote_burst_settings.config")

    -- Setup constants
    local item = get_config_parameter(config, "burstItem", "isl_skill_mote")

    local count_base = get_config_parameter(config, "burstCount", 5)
    local count_multiplier =
      get_config_parameter(config, "burstCountMultiplierPerLevel", 1)
    local burst_count =
      count_base * math.ceil(1+(monster.level() * count_multiplier))

    local velocity_range =
      get_config_parameter(config, "burstItemVelocityRange", {20, 40})

    local angle_variance =
      get_config_parameter(config, "burstItemAngleVariance", 0.5)

    local offset =
      get_config_parameter(config, "burstOffset", {0, 0})


    local position = vec2.add(entity.position(), offset)
    local stack_size_base = get_config_parameter(config, "burstStackSize", 5)
    local stack_size_multiplier =
      get_config_parameter(config, "burstStackSizeMultiplierPerLevel", 0)
    local stack_size =
      stack_size_base * math.ceil(1+(monster.level() * stack_size_multiplier))

    local parameters = nil
    local intangible_time_range =
      get_config_parameter(config, "burstIntangibleTimeRange", {0, 0})

    for _ = 1, burst_count, 1 do
      local velocity = vec2.withAngle(
        sb.nrand(angle_variance, math.pi / 2),
        util.randomInRange(velocity_range)
      )
      world.spawnItem(
        item,
        position,
        stack_size,
        parameters,
        velocity,
        util.randomInRange(intangible_time_range)
      )
    end
  end
)
