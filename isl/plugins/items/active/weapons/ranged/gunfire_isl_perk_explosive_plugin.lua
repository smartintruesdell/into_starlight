--[[
  The "Explosive" perk is supposed to make your explosions bigger and more powerful

  This is accomplished by replacing the stock explosive projectiles with bigger ones
]]
require "/isl/lib/log.lua"
require "/scripts/lpl_plugin_util.lua"

local EXPLOSIVE_PERK_EFFECT_NAME = "isl_perk_explosive"
local TYPE_REPLACEMENTS = {
  ["bomb"] = "isl_explosive_perk_bomb",
  ["rocketshell"] = "isl_explosive_perk_rocketshell",
  ["grenade"] = "isl_explosive_perk_grenade",
  ["stickygrenade"] = "isl_explosive_perk_stickygrenade"
}

GunFire.fireProjectile = Plugins.add_before_hook(
  GunFire.fireProjectile,
  function (self, projectileType, projectileParams, inaccuracy)
    local next_projectileType = projectileType

    if status.uniqueStatusEffectActive(EXPLOSIVE_PERK_EFFECT_NAME) then
      if
        projectileType and
        TYPE_REPLACEMENTS[projectileType]
      then
        next_projectileType = TYPE_REPLACEMENTS[projectileType]
        ISLLog.debug("%s -> %s", projectileType, next_projectileType)
      elseif
        self.projectileType and
        TYPE_REPLACEMENTS[self.projectileType]
      then
        next_projectileType = TYPE_REPLACEMENTS[self.projectileType]
        ISLLog.debug("%s -> %s", projectileType, next_projectileType)
      end
    end

    return self, next_projectileType, projectileParams, inaccuracy
  end
)
