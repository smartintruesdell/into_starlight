--[[
  A utility class for modeling IntoStarlight stat effects
]]
require "/scripts/util.lua"
require "/scripts/questgen/util.lua"
require "/isl/lib/util.lua"
require "/isl/held_items/held_items.lua"
require "/isl/player_stats/stat_effects_map.lua"

-- Constants ------------------------------------------------------------------

local PATH = "/isl/player_stats"

-- Utility Functions ----------------------------------------------------------

local function no_op() return ISLStatEffectsMap.new() end

local function get_effect_handlers()
  local config = root.assetJson(PATH.."/player_stats.config")

  local persistent, movement = {}, {}

  for stat_name, stat_data in pairs(config.stats or {}) do
    -- First, set a default value for each stat
    self[stat_name] = stat_data.default or 0

    -- Then, read in the persistent/movement effects handlers for the stat.
    -- Because Starbound's Lua implementation does not allow for modules
    -- to return values (boo), we have to use `_ENV` to extract them from the
    -- global namespace (boo) after loading them.
    if stat_data.script then
      require(stat_data.script)

      if stat_data.persistentEffectsHandler then
        assert(
          _ENV[stat_data.persistentEffectsHandler] ~= nil,
          string.format(
            "unable to load persistent effects handler %s for stat %s",
            stat_data.persistentEffectsHandler,
            stat_name
          )
        )
        persistent[stat_name] = _ENV[stat_data.persistentEffectsHandler]
      end
      if stat_data.movementEffectsHandler then
        assert(
          _ENV[stat_data.movementEffectsHandler] ~= nil,
          string.format(
            "unable to load movement effects handler `%s` for stat `%s`",
            stat_data.persistentEffectsHandler,
            stat_name
          )
        )
        movement[stat_name] = _ENV[stat_data.movementEffectsHandler] or no_op
      end
    end
  end

  return persistent, movement
end

-- Namespace ------------------------------------------------------------------

ISLPlayerStats = ISLPlayerStats or {}

-- Methods --------------------------------------------------------------------

--- Returns 'base' stats as persistent effects to be consumed by
--- derived stat generation and other effects.
function ISLPlayerStats.get_base_stat_persistent_StatEffects(_player, skill_graph)
  local results_map = ISLStatEffectsMap.new()

  -- First, we read in default stats from config
  local config = root.assetJson(PATH.."/player_stats.config")
  for stat_name, stat_data in pairs(config.stats or {}) do
    results_map:adjust_amount(stat_name, stat_data.default or 0)
  end

  -- Next, we read stats from the skill_graph
  for _, skill_id in ipairs(skill_graph.saved_skills:to_Vec()) do
    local skill = skill_graph.skills[skill_id]
    assert(
      skill ~= nil,
      string.format(
        "Unable to derive base stats from skill `%s`, which was not found",
        skill_id
      )
    )

    for stat_name, stat_value in pairs(skill.unlocks.stats or {}) do
      results_map:adjust_amount(stat_name, stat_value)
    end
  end

  return results_map:get_persistent_StatEffects()
end


--- Returns 'derived' stats, such as the attack power boost from Strength or
--- similar. This is where the majority of stat application work gets done.
---
--- Note we do NOT pass base stats into the handler; That's done by calling
--- status.stat() inside the handler, such that each handler can ensure it
--- receives the most complete value for those stats at the time of execution
function ISLPlayerStats.get_derived_stat_persistent_StatEffects(player)
  local persistent_effect_handlers = get_effect_handlers()

  local results_map = ISLStatEffectsMap.new()

  local held_items = ISLHeldItems.new():read_from_entity(player.id())

  for _, handler in pairs(persistent_effect_handlers or {}) do
    results_map = results_map:concat(handler(player.id(), held_items))
  end

  return results_map:get_persistent_StatEffects()
end


--- Returns derived `mcontroller` controlModifiers, which have to be applied
--- on Player.update.
---
--- Note we do NOT pass base stats into the handler; That's done by calling
--- status.stat() inside the handler, such that each handler can ensure it
--- receives the most complete value for those stats at the time of execution
function ISLPlayerStats.get_derived_stat_ActorMovementModifiers(entity_id)
  local _, movement_effect_handlers = get_effect_handlers()

  local results_map = ISLStatEffectsMap.new()

  local held_items = ISLHeldItems.new():read_from_entity(entity_id)

  for _, handler in pairs(movement_effect_handlers) do
    results_map = results_map:concat(handler(entity_id, held_items))
  end

  return results_map:get_ActorMovementModifiers()
end
