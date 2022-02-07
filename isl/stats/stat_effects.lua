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
require("/isl/log.lua")
require("/isl/stats/held_items.lua")
require("/isl/stats/stats.lua")

-- Class ----------------------------------------------------------------------

ISLStatEffects = createClass("ISLStatEffects")

ISLStatEffects.effect_category_identifier = "isl_stat_based_effects"

-- Constructor ----------------------------------------------------------------

function ISLStatEffects:init(entity_id)
   self.entity_id = entity_id
   self.state = {}

   -- Initialize state managers
   self.state.held_items = ISLHeldItemsManager.new(self.entity_id)
   self.state.stats = ISLPlayerStats.new()
end

-- Methods --------------------------------------------------------------------

function ISLStatEffects:update(dt)
   --ISLLog.debug("ISLStatEffects update")
   if self:update_state(dt) then
      self:apply_stat_modifiers()
      self:apply_movement_modifiers()
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

function ISLStatEffects:apply_stat_modifiers()
   local new_effects_map = {}

   new_effects_map = self:apply_strength_stat_effects(new_effects_map)

   local new_effects = {}
   for _, effect in pairs(new_effects_map) do
      table.insert(new_effects, effect)
   end

   status.setPersistentEffects(
      ISLStatEffects.effect_category_identifier,
      new_effects
   )
end
function ISLStatEffects:apply_movement_modifiers() end

function ISLStatEffects:apply_strength_stat_effects(effects_map)
   effects_map = effects_map or {}

   -- TODO: move this into a config
   local two_handed_power_ratio = 0.01
   local one_handed_power_ratio = 0.008
   effects_map.powerMultiplier = effects_map.powerMultiplier or {
      stat = "powerMultiplier",
      amount = 0,
      baseMultiplier = 1,
      effectiveMultiplier = 1
   }

   if self.state.held_items.primary then
      if self.state.held_items.primary.twoHanded then
         effects_map.powerMultiplier.amount =
            effects_map.powerMultiplier.amount +
            self.state.stats.isl_strength.current * two_handed_power_ratio
      else
         effects_map.powerMultiplier.amount =
            effects_map.powerMultiplier.amount +
            self.state.stats.isl_strength.current * one_handed_power_ratio
      end
   end
   return effects_map
end
