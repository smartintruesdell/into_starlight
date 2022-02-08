--[[
   Color management for IntoStarlight
]]
require("/isl/log.lua")

-- Globals --------------------------------------------------------------------

Colors = Colors or {}

-- Init -----------------------------------------------------------------------

local color_data = nil

function Colors.get_color(color_id)
   if not color_data then color_data = root.assetJson("/isl/colors.config") end

   local color_name = color_data.colorAlias[color_id]

   if color_data.color[color_name] then
      return color_data.color[color_name]
   elseif color_data.color[color_id] then
      return color_data.color[color_id]
   else
      ISLLog.warn("Invalid color alias '%s'", color_id)
      return color_data.color.cyan
   end
end
