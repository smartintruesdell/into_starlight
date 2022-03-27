--[[ Stat effect related utility functions ]]
require "/isl/lib/diminishing_returns.lua"
require "/isl/player_stats/stat_effects_map.lua"

local function get_stats_from_byTags(current_tags, byTags_method, byTags_config)
  local results = ISLStatEffect.new()
  for _, tag_effect in ipairs(byTags_config or {}) do
    if
      tag_effect.tags and
      util.all(
        tag_effect.tags,
        function (tag) return current_tags:contains(tag) end
      )
    then
      results = results:concat(ISLStatEffect.new(tag_effect))

      -- Early out if the byTagsMethod is not set to 'all'
      if byTags_method ~= "all" then break end
    end
  end

  return results
end

local function get_effects_from_config(held_items, config)
  stat_config = config or {}
  return ISLStatEffect.new(stat_config.always or {}):concat(
    get_stats_from_byTags(
      held_items.tags,
      stat_config.byTagsMethod or "first",
      stat_config.byTags or {}
    )
  )
end

--- Reads our stateffects config file and turns it into derived stats
---
--- @param held_items table @ ISLHeldItems : The player's held items
--- @param stat_name string @ The name of the base stat to use
--- @param config_path string @ the absolute path of the config file
--- @return table @ ISLStatEffectsMap
function get_derived_StatEffects_from_config(held_items, stat_name, config_path, results)
  local config = root.assetJson(config_path)
  local current_stat_points = status.stat(stat_name)
  results = results or ISLStatEffectsMap.new()

  -- For each derived stat in the config,
  for derived_stat, derived_stat_config in pairs(config) do
    -- Given the current value of the per_stat_point effect, we'll
    -- apply the stat number and then reduce by diminishing returns
    local function apply_stat_with_dr(value)
      if derived_stat_config.diminishingReturns then
        return diminishing_returns(
          derived_stat_config.diminishingReturns.rate or 10,
          derived_stat_config.diminishingReturns.start or 0,
          derived_stat_config.diminishingReturns.factor or 0.1,
          current_stat_points * value
        )
      else
        return current_stat_points * value
      end
    end

    -- Determine the initial 'base' state for that stat
    local base = get_effects_from_config(
      held_items,
      derived_stat_config.base
    ):default()

    -- And assemble the 'per point' state for that stat from its 'always'
    -- effect
    local per_stat_point =
      get_effects_from_config(
        held_items,
        derived_stat_config.perPoint
      ):over_all(apply_stat_with_dr)

    results:concat(
      ISLStatEffectsMap.new({
        [derived_stat] = base:concat(per_stat_point):set_stat(derived_stat)
      })
    )
  end

  return results
end
