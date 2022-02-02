--[[
   This module defines init and update behavior for the
   `isl_stat_effects` statuseffect. This is where basic stat updates
   are applied to the player such that the game state reflects the
   bonuses and penalties we expect from IntoStarlight's stats and
   skills-grid
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/stats/held_items.lua")

-- Class ----------------------------------------------------------------------

ISLStatEffects = createClass("ISLStatEffects")

ISLStatEffects.effect_category_identifier = "isl_stat_based_effects"

-- Constructor ----------------------------------------------------------------

function ISLStatEffects:init(entity_id)
   ISLLog.debug("ISLStatEffects Initializing...")

   self.entity_id = entity_id
   self.state = {}

   -- Initialize state managers
   self.state.held_items = ISLHeldItemsManager.new(self.entity_id)
end

-- Methods --------------------------------------------------------------------

function ISLStatEffects:update(dt)
   ISLLog.debug("ISLStatEffects update")
   if self:update_state(dt) then
      self:apply_stat_modifiers()
      self:apply_movement_modifiers()
   end
end

function ISLStatEffects:update_state(dt)
   local changed = false
   for _key, state_manager in pairs(self.state) do
      if state_manager['update'] ~= nil then
         ISLLog.debug('Gonna update the %s manager', _key)
         changed = state_manager:update(dt) or changed
      end
   end

   return changed
end

function ISLStatEffects:apply_stat_modifiers()
   local new_effects = {}

   table.insert(new_effects, { stat="powerMultiplier", amount=0.5 })

   status.setPersistentEffects(
      ISLStatEffects.effect_category_identifier,
      new_effects
   )
end
function ISLStatEffects:apply_movement_modifiers() end
