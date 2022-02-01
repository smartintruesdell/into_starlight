--[[
   Strings management for IntoStarlight
]]
require("/isl/log.lua")
-- Globals --------------------------------------------------------------------

Strings = Strings or {
   ready = false
}

-- Init -----------------------------------------------------------------------

function Strings.init()
   ISLLog.debug("Initializing Strings")
   strings_data = root.assetJson("/isl/strings.json")
   Strings.locale = Strings.locale or 'en_US'

   for string_id, string_data in pairs(strings_data) do
      Strings[string_id] = string_data
   end

   Strings.ready = true
end

function Strings.getString(string_id)
   if Strings[string_id] then
      if Strings[string_id][Strings.locale] then
         return Strings[string_id][Strings.locale]
      else
         ISLLog.warn("Unable to find a locale-appropriate string for '%s'", string_id)
         return Strings[string_id].en_US or string_id
      end
   else
      ISLLog.debug("Failed to find localizable string '%s'", string_id)
      return string_id
   end
end
