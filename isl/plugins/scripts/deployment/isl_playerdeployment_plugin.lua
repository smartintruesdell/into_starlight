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
  function (self)
    ISLLog.info("Initializing IntoStarlight Player Features")

    message.setHandler(
      "isl_skillgraph_updated",
      function()
        ISLLog.debug("Recieved message `isl_skillgraph_updated`")
        return skillgraph_updated_handler(self, player)
      end
    )

    self.skillgraph = ISLSkillGraph.initialize(player)

    skillgraph_updated_handler(self, player)
  end
)

function skillgraph_updated_handler(self, _)
  local base_stat_effects =
    self.skillgraph.stats:get_base_stat_persistent_effects()

  status.setPersistentEffects("isl_base_stats", base_stat_effects)
end

local PULSE_DELTA = 0.30 -- approx script.setUpdateDelta(30)
local pulse_timer = 0

local super_update = update
function update(dt)
  local stats = ISLPlayerStats.new(player.id())

  pulse_timer = pulse_timer + dt
  if pulse_timer >= PULSE_DELTA then
    pulse_timer = 0

    -- Do derived stat calculations only on the pulse
    status.setPersistentEffects(
      "isl_derived_stats",
      stats:get_derived_stat_persistent_effects()
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
  -- TODO: Gonna want to remove all the perks on the player
end
