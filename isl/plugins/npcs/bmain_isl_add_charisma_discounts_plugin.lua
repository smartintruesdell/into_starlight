--[[ Adds merchant price reduction based on the interacting player's charisma stat ]]
require "/scripts/lpl_plugin_util.lua"
require("/isl/player_stats/player_stats.lua")

interact_get_trading_config = Plugins.add_after_hook(
  interact_get_trading_config,
  function (result, args)
    local player_stats = ISLPlayerStats.new():read_from_entity(args.sourceId)
    local charisma_price_reduction = player_stats:get_charisma_price_reduction()

    result.buyFactor = result.buyFactor * charisma_price_reduction

    return result
  end
)
