--[[
  Status effect manager for the player's movement-based stat effects

  Because these have to be applied every frame (yuck), we can't just assign
  them the way we do with persistant effects in the playerdeployment plugin
]]
require "/isl/player_stats/player_stats.lua"
require "/isl/lib/log.lua"
require "/scripts/util.lua"

function init()
  script.setUpdateDelta(30)
end

function update(_)
  local modifiers =
    ISLPlayerStats.get_derived_stat_ActorMovementModifiers(entity.id())

  ISLLog.debug(util.tableToString(modifiers))

  mcontroller.controlModifiers(
    modifiers
  )
end

function uninit() end
