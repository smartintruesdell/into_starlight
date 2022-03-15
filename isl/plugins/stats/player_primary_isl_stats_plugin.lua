--[[ Add a hook to the Player to apply IntoStarlight stat effects]]
require "/isl/lib/log.lua"
require "/isl/skillgraph/skillgraph.lua"

require "/scripts/lpl_plugin_util.lua"

Plugins.add_after_initialize_hook(
  "player_primary",
  function(self, ...)
    message.setHandler(
      "isl_apply_stats_from_skill_graph",
      function(_, is_local, ...)
        return isl_apply_stats_from_skill_graph_handler(self, is_local, ...)
      end
    )

    return ...
  end
)


--- Called when the player deploys to an instance or world and applies persistant
--- stat effects to the player
function isl_apply_stats_from_skill_graph_handler(_self, is_local)
  -- First, we'll instantiate the skill graph
  local skill_graph = ISLSkillGraph.initialize(entity.id())

  -- Then we'll get the stats from the skill graph
  local stats = skill_graph.stats

  -- Then we'll transform those stats into the appropriate spread of
  -- persistent effects and we'll apply them to the player
  status.setPersistentEffects(
    "isl_base_stats",
    stats:get_base_stat_persistent_effects()
  )
end

local PULSE_DELTA = 0.30 -- approx script.setUpdateDelta(30)
local pulse_timer = 0

local super_update = update
function update(dt)
  local stats = ISLPlayerStats.new(entity.id())

  pulse_timer = pulse_timer + dt
  if pulse_timer >= PULSE_DELTA then
    pulse_timer = 0

    -- Do derived stat calculations only on the pulse
    status.setPersistentEffects(
      "isl_derived_stats",
      stats:get_derived_stat_persistent_effects()
    )
  end

  -- Apply movement based benefits every update, because they're short-lived
  mcontroller.controlModifiers(stats:get_derived_stat_movement_effects())

  return super_update(dt)
end
