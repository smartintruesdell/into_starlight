--[[ Derived stat effects for the IntoStarlight Celerity stat ]]
local _diminishing_returns = require("/isl/lib/diminishing_returns.lua")

local STAT_NAME = "isl_celerity"
local PATH = "/isl/player_stats/effects"

local function handler(entity_id, _held_items)
  local _config = root.assetJson(PATH.."/celerity.config")
  local _celerity = world.callScriptedEntity(
    entity_id,
    "status.stat",
    STAT_NAME
  )
  local results = {}

  return results
end

return handler
