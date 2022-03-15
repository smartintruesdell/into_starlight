--[[ Derived stat effects for the IntoStarlight Savagery stat ]]
local _diminishing_returns = require("/isl/lib/diminishing_returns.lua")

local STAT_NAME = "isl_savagery"
local PATH = "/isl/player_stats/effects"

local function handler(entity_id, _held_items)
  local _config = root.assetJson(PATH.."/savagery.config")
  local _savagery = world.callScriptedEntity(
    entity_id,
    "status.stat",
    STAT_NAME
  )
  local results = {}

  return results
end

return handler
