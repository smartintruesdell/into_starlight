--[[
  This module defines init and update behavior for the
  `isl_stat_effects` statuseffect. This is where basic stat updates
  are applied to the player such that the game state reflects the
  bonuses and penalties we expect from IntoStarlight's stats and
  skills-grid

  Note: I'm deliberately NOT instantiating a SkillGraph in this context.
  Doing so costs us ~2ms on load, and because this effect is being run
  really regularly we want to avoid doing that as much as possible.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/held_items/held_items.lua")
require("/isl/player/stats/player_stats.lua")

local PATH = "/isl/player/stats"
require(PATH.."/effects/effects_map.lua")

-- Utility functions ----------------------------------------------------------

---@param stat_value integer The player's current stat
---@param tags table (StringSet) a set of the tags on the user's primary item
---@param tag_tree table The tag tree with effect constants from config
local function get_effect_from_tag_tree(stat_value, tags, tag_tree)
  if not tag_tree then return nil end

  -- For each tag on the tree,
  for tag, child in pairs(tag_tree) do
    -- Skip the '__always' entry, that's special.
    if tag == "__always" then goto continue end

    -- If our held item has that tag,
    if tags:contains(tag) then
      -- If the subtree is a terminal amount/multiplier struct,
      if
        child.amount ~= nil or
        child.baseMultiplier ~= nil or
        child.effectiveMultiplier ~= nil
      then
        -- return the effect with the stat applied to it
        local effect = {}
        effect.amount = (child.amount and (child.amount * stat_value)) or 0
        effect.baseMultiplier = (child.baseMultiplier and (((child.baseMultiplier - 1) * stat_value) + 1)) or 1
        effect.effectiveMultiplier = (child.effectiveMultiplier and (((child.effectiveMultiplier - 1) * stat_value) + 1)) or 1

        -- Return the first valid result
        return effect
      else
        -- If its not a terminal amount/multiplier struct, we'll recurse
        -- down the tree
        local child_result = get_effect_from_tag_tree(stat_value, tags, child)

        -- Return the first valid child
        if child_result ~= nil then return child_result end
      end
    end
    ::continue::
  end

  return nil
end

-- Class ----------------------------------------------------------------------

ISLPlayerStatEffectsController = createClass("ISLStatEffects")

ISLPlayerStatEffectsController.effect_category_identifier = "isl_stat_based_effects"

-- Constructor ----------------------------------------------------------------

function ISLPlayerStatEffectsController:init(entity_id)
  self.entity_id = entity_id

  -- Initialize state managers
  self.state = {}
  local held_items, _ = ISLHeldItems.new():read_from_entity(entity_id)
  self.state.held_items = held_items

  local stats = ISLPlayerStats.new():read_from_entity(entity_id)
  self.state.stats = stats

  -- Initialize effect controllers Each is a module with a static `get_effects`
  -- function so that we can compartmentalize our effects logic. Note that each
  -- controller will recieve the full state along with the config tree.
  self.effect_configuration = {
    isl_strength = root.assetJson(PATH.."/effects/strength.config"),
    isl_precision = root.assetJson(PATH.."/effects/precision.config"),
    isl_wits = root.assetJson(PATH.."/effects/wits.config"),
    isl_defense = root.assetJson(PATH.."/effects/defense.config"),
    isl_focus = root.assetJson(PATH.."/effects/focus.config"),
    isl_vigor = root.assetJson(PATH.."/effects/vigor.config"),
    isl_mobility = root.assetJson(PATH.."/effects/mobility.config")
  }
end

-- Update ---------------------------------------------------------------------

function ISLPlayerStatEffectsController:update(--[[dt: number]])
  if self:update_state() then
    local effects_map = ISLEffectsMap.new()

    for stat, configuration in pairs(self.effect_configuration) do
      local stat_value =
        self.state.stats[stat].amount * self.state.stats[stat].multiplier

      for modifier, tag_tree in pairs(configuration) do
        local effect = get_effect_from_tag_tree(
          stat_value,
          self.state.held_items.tags,
          tag_tree
        )
        if effect ~= nil then
          effects_map:concat({
            [modifier] = effect
          })
        end

        if tag_tree.__always ~= nil then
          local always_effect = {}
          if tag_tree.__always.amount then
            always_effect.amount =
              tag_tree.__always.amount * stat_value
          end
          if tag_tree.__always.baseMultiplier then
            always_effect.baseMultiplier =
              tag_tree.__always.baseMultiplier * stat_value
          end
          if tag_tree.__always.effectiveMultiplier then
            always_effect.effectiveMultiplier =
              tag_tree.__always.effectiveMultiplier * stat_value
          end

          effects_map:concat({
            [modifier] = always_effect
          })
        end
      end
    end

    status.setPersistentEffects(
      ISLPlayerStatEffectsController.effect_category_identifier,
      effects_map:spread()
    )
  end
end

function ISLPlayerStatEffectsController:update_state()
  local stats_changed = false
  self.state.stats, stats_changed = self.state.stats:read_from_entity(self.entity_id)

  local items_changed = false
  self.state.held_items, items_changed = self.state.held_items:read_from_entity(self.entity_id)

  return stats_changed or items_changed
end

-- Methods --------------------------------------------------------------------
