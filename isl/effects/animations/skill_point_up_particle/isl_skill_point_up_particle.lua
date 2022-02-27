--[[
  A status effect script run when the player earns a Skill Point
  Applies a particle effect so you know it happened.
]]
require("/scripts/util.lua")
require("/isl/constants/strings.lua")
require("/isl/lib/log.lua")

local STATUS_EFFECT_PATH =
  "/isl/animations/skill_point_up/isl_skill_point_up_particle.statuseffect"

function init()
  ISLStrings.initialize()
  script.setUpdateDelta(5)
  self.status_config =
    root.assetJson(STATUS_EFFECT_PATH)

  status.setResourcePercentage("health", 1.0)
  status.setResourcePercentage("energy", 1.0)
end

function apply_visual_effects()
  -- Spawn the "Skill Up! text"
  world.spawnProjectile(
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
            text = "^shadow;"..Strings:getString(
              "skill_up_effect_label"
            ),
            color = {255, 215, 82, 180},
            fullbright = true,
            initialVelocity = {0.0, 15.0},
            finalVelocity = {0.0, 5},
            size = 1.2,
            approach = {3, 40},
            angularVelocity = 0,
            timeToLive = 0.5,
            layer = "front",
            destructionAction = "shrink",
            destructionTime = 0.5,
            variance = {},
            flippable = false
          }
        },
        {
          action = "particle",
          specification = {
            type = "animated",
            animation = "/animations/plasmapoof/plasmapoof.animation",
            fullbright = true,
            initialVelocity = {0.0, 0.0},
            finalVelocity = {0.0, 0},
            size = 1,
            approach = {0, 0},
            angularVelocity = 0,
            timeToLive = 0.5,
            layer = "back",
            destructionAction = "fade",
            destructionTime = 0.5,
            variance = {},
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
