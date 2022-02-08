--[[
   A type defintion for a StringSet
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Class ----------------------------------------------------------------------

StringSet = StringSet or createClass("StringSet")

-- Constructor ----------------------------------------------------------------

--- StringSet.new(string[]) -> StringSet
function StringSet:init(vec)
   self:add_many(vec or {})
end

-- Methods --------------------------------------------------------------------

function StringSet:add(value)
   self[value] = true

   return self
end

function StringSet:add_many(vec)
   vec = vec or {}
   for _, value in ipairs(vec) do
      self:add(value)
   end

   return self
end

function StringSet:remove(value)
   self[value] = nil

   return self
end

function StringSet:to_Vec()
   local res = {}

   for key, include in pairs(self) do
      if include then table.insert(res, key) end
   end

   return res
end

-- Predicates -----------------------------------------------------------------

function StringSet:contains(value)
   return self[value] or false
end
