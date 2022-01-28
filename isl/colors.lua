--[[
   Color management for IntoStarlight
]]
-- Globals --------------------------------------------------------------------

Colors = Colors or nil

-- Init -----------------------------------------------------------------------

local color_data = nil

function Colors.get_color(color_id)
   if not color_data then color_data = root.assetJson("/isl/colors.json") end

   local color_name = color_data.colorAlias[color_id]

   return color_data.color[color_name] or color_data.color[color_id] or color_data.color.cyan
end
