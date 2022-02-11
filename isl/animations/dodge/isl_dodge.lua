--[[
  A status effect script run when the player successfully dodges an attack.
  Applies a particle effect so you know it happened.
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")

function init()
  script.setUpdateDelta(5)
  self.status_config = root.assetJson("/isl/animations/dodge/isl_dodge.statuseffect")
  -- DEBUG - reset health on dodge so we can keep dodging forever
  status.setResourcePercentage("health", 1.0)
end

function apply_visual_effects()
  local statusTextRegion = { 0, 1, 0, 1 }
  animator.setParticleEmitterOffsetRegion("statustext", statusTextRegion)

  local projectile_id = world.spawnProjectile(
    "invisibleprojectile",
    mcontroller.position(),
    entity.id(),
    { 0, 0 },
    true,
    {
      timeToLive = 0,
      damageType = "NoDamage",
      actionOnReap = {
        {
          action = "particle",
          specification = {
            type = "text",
            text = "^shadow;Dodge!",
            color = {81, 185, 255, 180},
            fullbright = true,
            initialVelocity = {0.0, 15.0},
            finalVelocity = {0.0, -5},
            size = 0.8,
            approach = {3, 40},
            angularVelocity = 20,
            timeToLive = 0.5,
            layer = "front",
            destructionAction = "shrink",
            destructionTime = 0.5,
            variance = {
              initialVelocity= {12.0, 3.0}
            },
            flippable = false
          }
        }
      }
    }
  )
end

function update(_dt)
  if effect.duration() == self.status_config.defaultDuration then
    -- On our first update, our duration should == the default duration
    apply_visual_effects()
  end
end
