--[[ Adds critical hits to the Weapon:damageSource method ]]
require("/scripts/lpl_plugin_util.lua")
require("/isl/player/stats/player_stats.lua")

Weapon.damageSource = Plugins.add_after_hook(
  Weapon.damageSource,
  function(result)
    -- damageSource returns nil if there's no damageArea, so we'll
    -- respect that.
    if not result then return nil end

    -- Otherwise, get the player's critical hit chance
    local player_stats = ISLPlayerStats.new():read_from_entity(entity.id())
    local crit_chance = player_stats:get_critical_hit_chance()

    -- If the user has a critical hit chance and the attack was going to deal
    -- any damage,
    if result and result.damage ~= nil and crit_chance > 0 then
      -- Get the critical hit damage multiplier
      local crit_multiplier = player_stats:get_critical_hit_multiplier()

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
