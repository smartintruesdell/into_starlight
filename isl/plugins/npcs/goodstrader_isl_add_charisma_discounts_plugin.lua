--[[ Adds merchant price reduction based on the interacting player's charisma stat ]]

-- Using an oldstyle hook because handleInteract is an engine callback
local super_handleInteract = handleInteract
function handleInteract(_)
  local charisma_buyFactorMultiplier =
    status.stat("isl_charisma_buyFactor_multiplier")
  local charisma_sellFactorMultiplier =
    status.stat("isl_charisma_sellFactor_multiplier")

  local results = super_handleInteract()

  results[2].buyFactor = result.buyFactor * charisma_buyFactorMultiplier
  results[2].sellFactor = result.sellFactor * charisma_sellFactorMultiplier

  return results
end
