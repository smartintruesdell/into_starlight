--[[
  Strings management for IntoStarlight
]]
require("/isl/lib/log.lua")
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Globals --------------------------------------------------------------------

Strings = Strings or nil

-- Class ----------------------------------------------------------------------

ISLStrings = ISLStrings or createClass("ISLStrings")

function ISLStrings:init()
  ISLLog.debug("Initializing Strings")
  strings_data = root.assetJson("/isl/constants/strings.config")

  self.locale = strings_data.locale or 'en_US'

  for string_id, string_data in pairs(strings_data) do
    self[string_id] = string_data
  end
end

function ISLStrings.initialize()
  Strings = Strings or ISLStrings.new()
end

function ISLStrings:getString(string_id, default)
  assert(
    self ~= nil,
    "Remember to call Strings:getString and not Strings.getString"
  )
  assert(
    string_id ~= nil,
    "Tried to retrieve a nil string id. Make sure you call `Strings:getString` "..
    "and not `String.getString`"
  )
  default = default or string_id

  if self[string_id] then
    if self[string_id][Strings.locale] then
      return self[string_id][Strings.locale]
    else
      ISLLog.warn("Unable to find a locale-appropriate string for '%s'", string_id)

      return self[string_id].en_US or string_id
    end
  else
    ISLLog.warn("Failed to find localizable string '%s'", string_id)

    return default
  end
end
