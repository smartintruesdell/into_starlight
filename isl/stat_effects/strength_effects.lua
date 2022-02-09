--[[
  A stat effect controller for deriving Strength-related effects
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")

local PATH = "/isl/stat_effects"
local StrengthConfig = nil

-- Utility functions ----------------------------------------------------------

---@param stat_value integer The player's current stat
---@param tags table (StringSet) a set of the tags on the user's primary item
---@param tag_tree table The tag tree with effect constants from config
local function get_effect_from_tag_tree(stat_value, tags, tag_tree)
  if not tag_tree then return nil end

  -- For each tag on the tree,
  for tag, child in pairs(tag_tree) do
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
  end

  return nil
end

-- Namespace ------------------------------------------------------------------

ISLStrengthEffects = ISLStrengthEffects or {}

-- Methods --------------------------------------------------------------------

---@param state table The current status_effect state model (held items, etc)
function ISLStrengthEffects.get_modifiers(state)
  StrengthConfig = StrengthConfig or root.assetJson(PATH.."/strength_effects.config")

  local effects_map = ISLEffectsMap.new()

  for stat, tag_tree in pairs(StrengthConfig) do
    local effect = get_effect_from_tag_tree(
      state.stats.isl_strength.current,
      state.held_items.tags,
      tag_tree
    )
    effects_map = effects_map:concat({
      [stat] = effect
    })
  end

  return effects_map
end
