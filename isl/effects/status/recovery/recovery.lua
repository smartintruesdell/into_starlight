--[[
  This is a variation on the vanilla 'heal' effect that combines both a flat
  healing rate (like a bandage) with a percentaged-based healing rate (like
  a regeneration).

  This provides an effect with diminishing returns at high maximum health but
  which is still valuable in the early game.
]]
function init()
  -- Setup visual effect
  -- - Offset to the player's position
  animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
  -- - Set the emission rate
  animator.setParticleEmitterEmissionRate(
    "healing",
    config.getParameter("emissionRate", 3)
  )
  -- - Disable if the config specifices `particles` = false
  animator.setParticleEmitterActive(
    "healing",
    config.getParameter("particles", true)
  )

  -- Set update rate
  script.setUpdateDelta(5)

  -- Set healing ratios
  self.healingFlatRate =
    config.getParameter("healAmount", 30) / effect.duration()
  self.healingPercentRate =
    config.getParameter("healPercent", 10) / effect.duration()
end

function update(dt)
  -- It is not significant in which order these are applied.
  status.modifyResourcePercentage("health", self.healingPercentRate * dt)
  status.modifyResource("health", self.healingFlatRate * dt)
end

function uninit()

end
