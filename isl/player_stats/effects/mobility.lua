--[[ Derived stat effects for the IntoStarlight Mobility stat ]]
local _diminishing_returns = require("/isl/lib/diminishing_returns.lua")

local STAT_NAME = "isl_mobility"
local PATH = "/isl/player_stats/effects"

local function handler(entity_id, _held_items)
  local _config = root.assetJson(PATH.."/mobility.config")
  local _mobility = world.callScriptedEntity(
    entity_id,
    "status.stat",
    STAT_NAME
  )
  local results = {}

  return results
end

return handler
