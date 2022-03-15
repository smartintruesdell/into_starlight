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
        ISLLog.debug("Recieved message `isl_skillgraph_updated`")
        return skillgraph_updated_handler(self, player)
      end
    )

    ISLSkillGraph.initialize(player)
  end
)

function skillgraph_updated_handler(_self, player)
  ISLLog.debug("skillgraph_updated_handler()")
  -- Every time it updates in the UI context, we have to rebuild ours as well.
  SkillGraph:load_saved_skills(player)

  -- Then we can derive new base stats from the result
  local base_stat_effects =
    SkillGraph.stats:get_base_stat_persistent_effects()

  ISLLog.debug(util.tableToString(base_stat_effects))

  -- And apply them to the player as base stats
  status.setPersistentEffects("isl_base_stats", base_stat_effects)
end

-- Player Update --------------------------------------------------------------

local PULSE_DELTA = 1 -- approx script.setUpdateDelta(100)
local pulse_timer = 0

local super_update = update
function update(dt)
  pulse_timer = pulse_timer + dt
  if pulse_timer >= PULSE_DELTA then
    pulse_timer = 0

    -- Refresh unique status effects (species, perks)
    SkillGraph:apply_status_effects_to_player(player)

    status.setPersistentEffects(
      "isl_derived_stats",
      SkillGraph.stats:get_derived_stat_persistent_effects()
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

  self.skillgraph:remove_status_effects_from_player(player)
end
