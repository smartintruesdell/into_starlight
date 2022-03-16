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
  end
)

function skillgraph_updated_handler(_self, player)
  -- Every time it updates in the UI context, we have to rebuild ours as well.
  SkillGraph:load_saved_skills(player)

  local base_statEffects =
    ISLPlayerStats.get_base_stat_persistent_StatEffects(player, SkillGraph)

  -- Then we can derive new base stats from the result
  status.setPersistentEffects(
    "isl_base_stats",
    base_statEffects
  )
end

-- Player Update --------------------------------------------------------------

local function db_log(value)
  local msg
  if type(value) == "table" then
    msg = util.tableToString(value)
  else
    msg = value
  end
  ISLLog.debug("%s", msg)

  return value
end

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
    --status.addEphemeralEffect("isl_movement_stat_effects", math.huge)

    -- Refresh unique status effects (species, perks)
    SkillGraph:apply_status_effects_to_player(player)

    local start_time = os.clock()
    local derived_stats =
      ISLPlayerStats.get_derived_stat_persistent_StatEffects(player)
    local elapsed_time = os.clock()-start_time
    ISLLog.debug("Stat calculation took %f seconds", elapsed_time)

    -- Apply derived stats from the player's base stats
    status.setPersistentEffects(
      "isl_derived_stats",
      db_log(derived_stats)
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

  --status.RemoveEphemeralEffect("isl_movement_stat_effects")
  SkillGraph:remove_status_effects_from_player(player)
end
