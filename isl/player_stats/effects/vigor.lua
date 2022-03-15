--[[ Derived stat effects for the IntoStarlight Vigor stat ]]
local _diminishing_returns = require("/isl/lib/diminishing_returns.lua")

local STAT_NAME = "isl_vigor"
local PATH = "/isl/player_stats/effects"

local function handler(entity_id, _held_items)
  local _config = root.assetJson(PATH.."/vigor.config")
  local _vigor = world.callScriptedEntity(
    entity_id,
    "status.stat",
    STAT_NAME
  )
  local results = {}

  return results
end

return handler
