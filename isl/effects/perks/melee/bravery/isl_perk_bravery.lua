--[[
  The Bravery perk is a defensive invulnerability frames perk that triggers
  when the player takes a big hit all at once.
]]
require("/scripts/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")

-- Effect  --------------------------------------------------------------------

--- Called when the effect (perk) is applied to an entity (player)
function init()
  script.setUpdateDelta(10)

  self.cooldown = config.getParameter("cooldown")
  self.cooldown_start = 0
end

function update(dt)
  -- First, check if the effect is on cooldown.
  if os.time() - self.cooldown_start >= self.cooldown then
    return
  end
end
