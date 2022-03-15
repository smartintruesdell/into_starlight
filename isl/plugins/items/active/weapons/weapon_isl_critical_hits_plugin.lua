--[[ Adds critical hits to the Weapon:damageSource method ]]
require("/scripts/lpl_plugin_util.lua")

Weapon.damageSource = Plugins.add_after_hook(
  Weapon.damageSource,
  function(result)
    -- damageSource returns nil if there's no damageArea, so we'll
    -- respect that.
    if not result then return nil end

    -- Otherwise, get the player's critical hit chance
    local crit_chance = status.stat("isl_crit_chance")

    -- If the user has a critical hit chance and the attack was going to deal
    -- any damage,
    if result and result.damage ~= nil and crit_chance > 0 then
      -- Get the critical hit damage multiplier
      local crit_multiplier = status.stat("isl_crit_multiplier")

      -- Roll for crit!
      local roll = math.random(100)
      if roll <= crit_chance then
        -- TODO: Add a visual effect?
        result.damage = result.damage + result.damage * crit_multiplier
      end
    end

    return result
  end
)
