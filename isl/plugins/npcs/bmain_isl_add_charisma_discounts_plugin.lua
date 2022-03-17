--[[ Adds merchant price reduction based on the interacting player's charisma stat ]]
require "/scripts/lpl_plugin_util.lua"

interact_get_trading_config = Plugins.add_after_hook(
  interact_get_trading_config,
  function (result, _)
    local charisma_buyFactorMultiplier =
      status.stat("isl_charisma_buyFactor_multiplier")
    local charisma_sellFactorMultiplier =
      status.stat("isl_charisma_sellFactor_multiplier")

    result.buyFactor = result.buyFactor * charisma_buyFactorMultiplier
    result.sellFactor = result.sellFactor * charisma_sellFactorMultiplier

    return result
  end
)
