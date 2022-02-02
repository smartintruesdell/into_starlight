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

-- Constructor ----------------------------------------------------------------

function ISLStatEffects:init()
   ISLLog.debug("ISLStatEffects Initializing...")
end

-- Methods --------------------------------------------------------------------

function ISLStatEffects:update(--[[dt: number]])
   ISLLog.debug("ISLStatEffects update")
end
