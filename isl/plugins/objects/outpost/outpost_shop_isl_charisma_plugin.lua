--[[ Adds a charisma based price reduction to the terramart ]]
require "/isl/player/stats/player_stats.lua"

onInteraction = onInteraction or function() end
local super_onInteraction = onInteraction

onInteraction = function(args)
  local interact_data = config.getParameter("interactData")

  local super_result = super_onInteraction(args)

  if super_result and super_result[2] then
    interact_data = super_result[2]
  end

  local player_stats = ISLPlayerStats.new():read_from_entity(args.sourceId)
  local charisma_price_reduction = player_stats:get_charisma_price_reduction()

  interact_data.buyFactor = interact_data.buyFactor * charisma_price_reduction

  return { "OpenMerchantInterface", interact_data }
end
