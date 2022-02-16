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
require("/isl/lib/string_set.lua")

-- Effect  --------------------------------------------------------------------

--- Called when the effect (perk) is applied to an entity (player)
function init()
  script.setUpdateDelta(10)

  -- We count hits where the regeneration bonus did NOT apply so that we can
  -- increase the chance of it happening on subsequent hits
  self.hit_kinds = StringSet.new(config.getParameter("hitKinds", {}))
  self.chance_on_hit = config.getParameter("chanceOnHit", 10.0)
  self.bonus_per_miss = config.getParameter("chanceBonusPerMiss", 1.0)
  self.bonus_duration = config.getParameter("chanceBonusDuration", 5)
  self.bonus_limit = config.getParameter("chanceBonusMaximum", 10)

  self.cooldown = config.getParameter("cooldown", 20)
  self.cooldown_start = 0

  self.regen_effect =
    config.getParameter("regenerationEffect", "regeneration1")

  self.hits_without_bonus = 0
  self.bonus_timeout = 0
  _,self.damageUpdate = status.damageTakenSince()
end

function update(dt)
  -- First, check if the effect is on cooldown.
  if os.time() - self.cooldown_start >= self.cooldown then
    self.notifications, self.damageUpdate = status.damageTakenSince(self.damageUpdate)

    -- For each hit notification
    for _, notification in pairs(self.notifications or {}) do
      -- If that hit was a qualifying hit kind
      if self.hit_kinds:contains(notification.damageSourceKind) then
        -- Determine our effect chance from base rate plus bonuses
        local effect_chance =
          self.chance_on_hit + math.min(
            self.bonus_limit,
            (self.bonus_per_miss * self.hits_without_bonus)
          )
        local roll = math.random(100)

        -- If we should apply the effect based on chance,
        if roll <= effect_chance then
          status.addEphemeralEffect(self.regen_effect)
          self.hits_without_bonus = 0
          self.cooldown_start = os.time()
        else
          -- Otherwise, increment our bonus and reset our bonus timeout
          self.hits_without_bonus = self.hits_without_bonus + 1
          self.bonus_timeout = os.time()
        end
      end
    end

    -- Handle timing out the bonus
    if
      self.hits_without_bonus > 0 and
      os.time() - self.bonus_timeout > self.bonus_duration
    then
      self.hits_without_bonus = 0
      self.bonus_timeout = 0
    end
  end
end
