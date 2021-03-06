--[[
  A script provided to allow monsters to drop Into Starlight skill motes

  This is preferred to using treasure pools because of how skill mote scaling works:
  The amount of motes a monster drops scales not by the level of the monster, but by
  the RELATIVE level of the player to the monster at the time of death.
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/util.lua")
require("/isl/skill_points/skill_points.lua")
require("/isl/plugins/spawn_skill_motes.lua")

require("/scripts/lpl_plugin_util.lua")

applyDamageRequest_update_hit_type = Plugins.add_after_hook(
  applyDamageRequest_update_hit_type,
  function (hit_type, damage_request)
    -- Then check for death
    if hit_type == "kill" then
      isl_spawn_skill_motes(damage_request)
    end

    return hit_type
  end
)

function isl_spawn_skill_motes(damage_request)
  -- Bail out for critters
  if entity.damageTeam().type == "passive" then return end

  -- Determine the relative player level
  local player_level = ISLSkillPoints.get_effective_level(
    damage_request.sourceEntityId
  )
  local monster_level = world.callScriptedEntity(entity.id(),"monster.level")

  spawn_skill_motes(
    entity.position(),
    player_level,
    monster_level
  )
end
