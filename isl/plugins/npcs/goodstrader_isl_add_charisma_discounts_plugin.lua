--[[ Adds merchant price reduction based on the interacting player's charisma stat ]]
require("/isl/player/stats/player_stats.lua")

-- Using an oldstyle hook because handleInteract is an engine callback
local super_handleInteract = handleInteract
function handleInteract(args)
  sb.logInfo("Plugin ran, alright.")
  local player_stats = ISLPlayerStats.new():read_from_entity(args.sourceId)
  local charisma_price_reduction = player_stats:get_charisma_price_reduction()
  local charisma_sell_price_increase = player_stats:get_charisma_sell_price_increase()

  local results = super_handleInteract()

  results[2].buyFactor = results[2].buyFactor * charisma_price_reduction
  results[2].sellFactor = results[2].sellFactor * charisma_sell_price_increase

  return results
end
