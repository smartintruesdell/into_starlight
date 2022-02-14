--[[
  The Warrior perk provides some useful early-game support for melee playstyles but
  does not scale well into endgame. It is meant to be a bit of a rite-of-passage
  into the rest of the melee tree, and is not a build-around in and of itself.

  ### The Warrior
  When you are hit by melee attacks, has a chance to provide minor health
  regeneration.

  Bonuses: (Static bonuses are provided in the skill definition)
  - +5% Strength
  - +5% Defense
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")

-- Constants ------------------------------------------------------------------

local EFFECT_GROUP_ID = "isl_perk_the_warrior"
local REGENERATION_DURATION = 5

-- Effect  --------------------------------------------------------------------

--- Called when the effect (perk) is applied to an entity (player)
function init()
  ISLLog.debug("The Warrior is INITIALIZING")
  -- We count hits where the regeneration bonus did NOT apply so that we can
  -- increase the chance of it happening on subsequent hits
  self.hits_without_bonus = 0
  self.timer = nil
  _,self.damageUpdate = status.damageTakenSince()
end

function update(dt)
  ISLLog.debug("The Warrior is UPDATING")

  self.notifications, self.damageUpdate = status.damageTakenSince(self.damageUpdate)
  ISLLog.debug(util.tableToString(self.damageUpdate))

  for _, notification in pairs(self.notifications or {}) do
    ISLLog.debug(util.tableToString(notification))
    -- if notification.hitType is melee somehow? then
    -- add a health regeneration effect
  end
end
