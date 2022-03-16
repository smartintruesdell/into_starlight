--[[ Derived stat effects for the IntoStarlight Focus stat ]]
require "/isl/player_stats/stat_effects_map.lua"
require "/isl/player_stats/effects/util.lua"

local STAT_NAME = "isl_focus"
local PATH = "/isl/player_stats/effects"
local CONFIG_PATH = PATH.."/focus.config"

--- Handler :: (string, ISLHeldItems) -> ISLStatEffectsMap
function get_focus_StatEffects(entity_id, held_items)
  local results = ISLStatEffectsMap.new()

  -- Do standard derived stats from the config file
  results:concat(
    get_derived_StatEffects_from_config(
      held_items,
      STAT_NAME,
      CONFIG_PATH
    )
  )

  -- Do any stat-specific handling

  return results
end
