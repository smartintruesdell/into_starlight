--[[ Adds a charisma based price reduction to the terramart ]]

onInteraction = onInteraction or function() end
local super_onInteraction = onInteraction

onInteraction = function(args)
  local interact_data = config.getParameter("interactData")

  local super_result = super_onInteraction(args)

  if super_result and super_result[2] then
    interact_data = super_interact_data[2]
  end

  local charisma_buyFactorMultiplier =
    status.stat("isl_charisma_buyFactor_multiplier")
  local charisma_sellFactorMultiplier =
    status.stat("isl_charisma_sellFactor_multiplier")

  interact_data.buyFactor = interact_data.buyFactor * charisma_buyFactorMultiplier
  interact_data.sellFactor = interact_data.sellFactor * charisma_sellFactorMultiplier

  return { "OpenMerchantInterface", interact_data }
end
