--[[
   Strings management for IntoStarlight
]]
-- Globals --------------------------------------------------------------------

Strings = Strings or nil

-- Init -----------------------------------------------------------------------

function initialize_Strings()
   Strings = root.assetJson("/isl/strings.json")
   Strings.locale = Strings.locale or 'en_US'
end
