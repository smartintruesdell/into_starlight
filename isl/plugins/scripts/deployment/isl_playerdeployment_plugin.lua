--[[
  This Plugin script is called when the player is spawned into the world, and
  sets up the components of IntoStarlight that impact Player stats/equipment/etc.
]]
require "/isl/lib/log.lua"

-- Player Initialization ------------------------------------------------------
--- I defer this into a run-once in the update event because otherwise I can't
--- access the `world.sendEntityMessage` function
local run_on_update = 200
local super_update = update
function update(...)
  super_update(...)
  if run_on_update and run_on_update == 0 then
    run_on_update = nil

    ISLLog.info("Initializing IntoStarlight Player Features")
    world.sendEntityMessage(player.id(), "isl_apply_stats_from_skill_graph")
  elseif run_on_update then
    run_on_update = run_on_update - 1
  end

  return ...
end


-- Player Destruction ---------------------------------------------------------
-- - Uses raw hook because this is an engine callback
local super_uninit = uninit
function uninit()
  super_uninit()
  ISLLog.info("Cleaning up IntoStarlight Player Features")
  -- TODO: Gonna want to remove all the perks on the player
end
