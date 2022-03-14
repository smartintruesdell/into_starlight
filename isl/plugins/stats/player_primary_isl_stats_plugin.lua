--[[ Add a hook to the Player to apply IntoStarlight stat effects]]
require "/scripts/lpl_plugin_util.lua"

Plugins.add_after_initialize_hook(
  "player_primary",
  function(self, ...)
    sb.logInfo("setting message handler")
    message.setHandler(
      "isl_apply_stats_from_skill_graph",
      function(...) return isl_apply_stats_from_skill_graph_handler(self, ...) end
    )

    return ...
  end
)


function isl_apply_stats_from_skill_graph_handler(_self, _, _)
  sb.logInfo("Received `isl_apply_stats_from_skill_graph` message")
end
