--[[
  A script provided to allow monsters to drop Into Starlight skill motes
  Add this to `/baseParameters/statusSettings/primaryScriptSources/-` on your monsters

  This is preferred to using treasure pools because of how skill mote scaling works:
  The amount of motes a monster drops scales not by the level of the monster, but by
  the RELATIVE level of the player to the monster at the time of death.
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/util.lua")
require("/isl/player/skill_points/skill_points.lua")

local no_op = function() end
local super_init = init or no_op
local super_applyDamageRequest = applyDamageRequest or no_op

function init()
  return super_init()
end

function applyDamageRequest(damageRequest)
  -- Apply normal hit logic first
  local damage_result = super_applyDamageRequest(damageRequest)

  -- Then check for death
  if not status.resourcePositive("health") then
    local player_level = ISLSkillPoints.get_effective_level(
      damageRequest.sourceEntityId
    )
    local monster_level = world.callScriptedEntity(entity.id(),"monster.level")
    local relative_pool_level = 2 + ISLUtil.clamp(
      -2,
      2,
      monster_level - player_level
    )

    ISLLog.debug(
      "Kill! P:%f M:%f, R:%f",
      player_level,
      monster_level,
      relative_pool_level
    )

    local res = world.spawnTreasure(
      entity.position(),
      "isl_skillmotepool",
      relative_pool_level
    )
    if not res then
      ISLLog.debug("Something went wrong spawning motes")
    end
  end

  return damage_result
end
