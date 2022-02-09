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
require("/isl/stats/stats.lua")

local PATH = "/isl/stat_effects"
require(PATH.."/effects_map.lua")
require(PATH.."/strength_effects.lua")

-- Class ----------------------------------------------------------------------

ISLStatEffects = createClass("ISLStatEffects")

ISLStatEffects.effect_category_identifier = "isl_stat_based_effects"

-- Constructor ----------------------------------------------------------------

function ISLStatEffects:init(entity_id)
  self.entity_id = entity_id

  -- Initialize state managers
  self.state = {}
  self.state.held_items = ISLHeldItemsManager.new(self.entity_id)
  self.state.stats = ISLPlayerStats.new(self.entity_id)

  -- Initialize effect controllers Each is a module with a static `get_effects`
  -- function so that we can compartmentalize our effects logic. Note that each
  -- controller will recieve the full state along with the config tree.
  self.effect_controllers = {
    ISLStrengthEffects
  }
end

-- Update ---------------------------------------------------------------------

function ISLStatEffects:update(dt)
  if self:update_state(dt) then
    local effects_map = ISLEffectsMap.new()

    for _, controller in ipairs(self.effect_controllers) do
      effects_map:concat(controller.get_modifiers(self.state))
    end

    status.setPersistentEffects(
      ISLStatEffects.effect_category_identifier,
      effects_map:spread()
    )
  end
end

function ISLStatEffects:update_state(dt)
  local changed = false
  for _, state_manager in pairs(self.state) do
    if state_manager['update'] ~= nil then
      changed = state_manager:update(dt) or changed
    end
  end

  return changed
end

-- Methods --------------------------------------------------------------------
