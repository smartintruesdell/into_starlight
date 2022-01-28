--[[
   Strings management for IntoStarlight
]]
-- Globals --------------------------------------------------------------------

ISLStrings = ISLStrings or {}

-- Init -----------------------------------------------------------------------

function Load_ISL_Strings()
   ISLStrings = root.assetJson("/isl/strings.json")
   ISLStrings.locale = ISLStrings.locale or 'en_US'
end
