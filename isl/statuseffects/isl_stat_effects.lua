--[[
   This script defines the logic by which the player's stats from the IntoStarlight
   mod are applied to their damage/health/etc.
]]
function init()
   -- Change the status effect to only check for updates every 15 ticks
   script.setUpdateDelta(15)

   -- Configure effect variables and load data
end

function update(dt)
   -- update local stats from the SkillGraph

   -- For each stat, update our category of persistent effects to apply
   -- the correct modifiers given the context of the player's skill graph
   -- and current equipment

end
