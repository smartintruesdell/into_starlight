--[[
  This Plugin script is called when the player is spawned into the world, and
  sets up the components of IntoStarlight that impact Player stats/equipment/etc.
]]
require "/scripts/util.lua"
require "/isl/lib/log.lua"
require "/isl/player_stats/player_stats.lua"
require "/isl/skillgraph/skillgraph.lua"

require "/scripts/lpl_plugin_util.lua"

-- Player Initialization ------------------------------------------------------

Plugins.add_after_initialize_hook(
  "playermechdeployment",
  function ()
    ISLLog.info("Initializing IntoStarlight Player Features")

    message.setHandler(
      "isl_skillgraph_updated",
      function()
        return skillgraph_updated_handler(self, player)
      end
    )
  end
)

function skillgraph_updated_handler(_self, player)
  -- Every time it updates in the UI context, we have to rebuild ours as well.
  SkillGraph:load_saved_skills(player)

  local base_statEffects =
    ISLPlayerStats.get_stats_for_saved_skills(
      player,
      SkillGraph
    ):get_persistent_StatEffects()

  -- Then we can derive new base stats from the result
  status.setPersistentEffects(
    "isl_base_stats",
    base_statEffects
  )
end

-- Player Update --------------------------------------------------------------

local run_once = true
local PULSE_DELTA = 1 -- approx script.setUpdateDelta(100)
local pulse_timer = 0

local super_update = update
function update(dt)
  -- On the first update, we'll initialize the SkillGraph and get our base
  -- stats applied to the player.
  if run_once then
    run_once = nil
    ISLSkillGraph.initialize(player):write_skills_to_player(player)
  end

  pulse_timer = pulse_timer + dt
  if not run_once and pulse_timer >= PULSE_DELTA then
    pulse_timer = 0

    -- Refresh the status effect that manages movement related stat effects
    status.addEphemeralEffect("isl_movement_stats_manager", math.huge)
    -- Refresh the status effect that manages skill point "level up" events
    status.addEphemeralEffect("isl_skill_points_manager", math.huge)

    -- Refresh unique status effects (species, perks)
    SkillGraph:apply_status_effects_to_player(player)

    -- Apply derived stats from the player's base stats
    status.setPersistentEffects(
      "isl_derived_stats",
      ISLPlayerStats.get_derived_stat_persistent_StatEffects(player)
    )
  end

  return super_update(dt)
end


-- Player Destruction ---------------------------------------------------------
-- - Uses raw hook because this is an engine callback
local super_uninit = uninit
function uninit()
  super_uninit()
  ISLLog.info("Cleaning up IntoStarlight Player Features")

  status.removeEphemeralEffect("isl_movement_stats_manager")
  status.removeEphemeralEffect("isl_skill_points_manager")

  SkillGraph:remove_status_effects_from_player(player)
end
