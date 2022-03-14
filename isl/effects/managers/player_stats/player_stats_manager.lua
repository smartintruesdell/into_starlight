--[[
  This script defines the logic by which the player's stats from the IntoStarlight
  mod are applied to their damage/health/etc.
]]
-- require "/isl/effects/managers/player_stats/base_stats_controller.lua"
-- require "/isl/effects/managers/player_stats/derived_stats_controller.lua"

-- require "/scripts/lpl_load_plugins.lua"
-- local PLUGINS_PATH =
--   "/isl/effects/managers/player_stats/player_stats_manager_plugins.config"

function init()
  -- Change the status effect to only check for updates every 30 ticks, which
  -- is approximately half of a second
  script.setUpdateDelta(30)

  -- self.controllers = init_sequence_controllers(self, entity.id())
end
--init = PluginLoader.add_plugin_loader("player_stats_manager", PLUGINS_PATH, init)


function update(dt)
  -- for _, controller in ipairs(self.controllers) do controller:update(dt) end
end

-- Sequences the player's stat related controller logic.
-- Separating these into individual status effects would not allow us to do sequencing
-- and dependencies management in this way, and could cause us to instantiate the
-- skill graph more than once (which would be bad for performance)
function init_sequence_controllers(self, player_id)
  -- controllers :: { update: () -> void }[]
  local controllers = {}
  -- The ISLStatsController reads the player's stats from the Skill Graph to
  -- determine base stat `amount`s. This should be first.
  controllers = init_add_stats_controller(self, player_id, controllers)

  -- The ISLStatEffectsController transforms stats into their derived effects,
  -- such as turning Strength into attack power for melee weapons.
  -- This needs to run AFTER the stats controller updates the stats.
  controllers = init_add_stat_effects_controller(self, player_id, controllers)

  return controllers
end

function init_add_stats_controller(_, player_id, controllers)
  table.insert(controllers, ISLStatsController.new(player_id))

  return controllers
end

function init_add_stat_effects_controller(_, player_id, controllers)
  table.insert(controllers, ISLStatEffectsController.new(player_id))

  return controllers
end
