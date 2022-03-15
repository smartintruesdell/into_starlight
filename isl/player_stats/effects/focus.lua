--[[ Derived stat effects for the IntoStarlight Focus stat ]]
local _diminishing_returns = require("/isl/lib/diminishing_returns.lua")

local STAT_NAME = "isl_focus"
local PATH = "/isl/player_stats/effects"

local function handler(entity_id, _held_items)
  local _config = root.assetJson(PATH.."/focus.config")
  local _focus = world.callScriptedEntity(
    entity_id,
    "status.stat",
    STAT_NAME
  )
  local results = {}

  return results
end

return handler
