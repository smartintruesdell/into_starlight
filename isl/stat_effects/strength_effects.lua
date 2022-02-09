--[[
  A stat effect controller for deriving Strength-related effects
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")

local PATH = "/isl/stat_effects"
local StrengthConfig = nil

-- Namespace ------------------------------------------------------------------

ISLStrengthEffects = ISLStrengthEffects or {}

-- Methods --------------------------------------------------------------------

---@param state table The current status_effect state model (held items, etc)
function ISLStrengthEffects.get_modifiers(state)
  StrengthConfig = StrengthConfig or root.assetJson(PATH.."/strength_effects.config")

  local effects_map = ISLEffectsMap.new()



  return effects_map
end
