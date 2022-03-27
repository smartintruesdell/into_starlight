--[[ Species effect for 'default' species without their own config]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")

-- Functions ------------------------------------------------------------------

local function get_species_persistent_effects()
  local base_stats = config.getParameter("baseStats") or {}
  local results = {}
  for stat_name, effect in pairs(base_stats) do
    effect.stat = stat_name
    results[#results+1] = effect
  end

  return results
end

-- Effect  --------------------------------------------------------------------

function init()
  script.setUpdateDelta(30)

  effect.addStatModifierGroup(
    get_species_persistent_effects()
  )
end
