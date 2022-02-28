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
  assert(self ~= nil, "Remember to use StringSet:add instead of StringSet.add")
  self[value] = true

  return self
end

function StringSet:add_many(vec)
  assert(self ~= nil, "Remember to use StringSet:add_many instead of StringSet.add_many")
  assert(vec ~= nil, "Tried to add an empty vector to a StringSet")
  for _, value in ipairs(vec) do
    self:add(value)
  end

  return self
end

function StringSet.union(a, b)
  return StringSet.new():add_many(a:to_Vec()):add_many(b:to_Vec())
end

function StringSet:remove(value)
  assert(self ~= nil, "Remember to use StringSet:remove instead of StringSet.remove")
  self[value] = nil

  return self
end

function StringSet:remove_many(vec)
  assert(self ~= nil, "Remember to use StringSet:remove_many instead of StringSet.remove_many")
  vec = vec or {}
  for _, value in ipairs(vec) do
    self:remove(value)
  end

  return self
end

function StringSet:to_Vec()
  assert(self ~= nil, "Remember to use StringSet:to_Vec instead of StringSet.to_Vec")
  local res = {}

  for key, include in pairs(self) do
    if include then table.insert(res, key) end
  end

  return res
end

function StringSet:clone()
  return StringSet.new(self:to_Vec())
end

function StringSet:size()
  local size = 0
  for _key, include in pairs(self) do
    if include then size = size + 1 end
  end
  return size
end

-- Predicates -----------------------------------------------------------------

function StringSet:contains(value)
  assert(self ~= nil, "Remember to use StringSet:contains instead of StringSet.contains")
  return self[value] or false
end

function StringSet:equals(other)
  if self:size() ~= other:size() then return false end
  for key, include in pairs(self) do
    if include and not other:contains(key) then return false end
  end
  return true
end
