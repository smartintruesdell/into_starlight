--[[
  The Bravery perk makes it so that every time you take > `n%` of your max health
  in damage, you're invulnerable for `m` seconds.

  This is similar to the default hit invulnerability, but has a higher threshold
  and lasts longer.
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")

-- Effect  --------------------------------------------------------------------

--- Called when the effect (perk) is applied to an entity (player)
function init()
  script.setUpdateDelta(10)

  self.cooldown = config.getParameter("cooldown", 20)
  self.cooldown_start = 0
  self.threshold = config.getParameter("hitPercentDamageThreshold", 0.2)
  self.duration = config.getParameter("invulnerabilityDuration", 5)
  self.ignore_fall_damage = config.getParameter("ignoreFallDamage", true)

  self.invuln_effect =
    config.getParameter("invulnerabilityEffect", "invulnerability")

  _,self.damageUpdate = status.damageTakenSince()
end

function update(_dt)
  -- First, check if the effect is on cooldown.
  if os.time() - self.cooldown_start >= self.cooldown then
    self.notifications, self.damageUpdate = status.damageTakenSince(self.damageUpdate)

    local life_loss_threshold = status.resourceMax("health") * self.threshold

    -- For each hit notification
    for _, notification in pairs(self.notifications or {}) do
      if
        -- If that hit was not fall damage or we don't care about fall damage
        (not self.ignore_fall_damage or notification.damageType ~= "fallDamage") and
        -- and the hit was big enough
        notification.damage >= life_loss_threshold
      then
        -- Add the invulnerability effect
        status.addEphemeralEffect(self.invuln_effect, self.duration)
        -- set the cooldown
        self.cooldown_start = os.time()
      end
    end
  end
end
