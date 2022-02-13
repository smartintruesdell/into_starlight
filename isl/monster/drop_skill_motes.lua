require("/scripts/util.lua")
require("/isl/lib/log.lua")

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
    ISLLog.debug(util.tableToString(damageRequest or {}))
    ISLLog.debug(util.tableToString(player or {}))
    ISLLog.debug(util.tableToString(("").player or {}))
    local res = world.spawnTreasure(
      entity.position(),
      "isl_skillmotepool",
      world.callScriptedEntity(entity.id(),"monster.level")
    )
    if not res then
      ISLLog.debug("Something went wrong spawning motes")
    end
  end

  return damage_result
end
