--[[
   Abstraction over two-Point "bounds" used for collision detection
   and layout
]]
require("/scripts/questgen/util.lua")
require("/isl/point.lua")

--- Models a 2d bounding box
Bounds = createClass("Bounds")

--- Bounds constructor
function Bounds:init(p1, p2)
   self.min = Point.new(
      {
         math.min(p1[1], p2[1]),
         math.min(p1[2], p2[2])
      }
   )
   self.max = Point.new(
      {
         math.max(p1[1], p2[1]),
         math.max(p1[2], p2[2])
      }
   )
   self._points = {
      self.min,
      Point.new({ self.min[1], self.max[2] }),
      self.max,
      Point.new({ self.max[1], self.min[2] })
   }
end

--- Returns true if the specified x,y coordinates are within bounds
function Bounds:contains(p)
   return p[1] > self.min[1] and p[1] < self.max[1] and p[2] > self.min[2] and p[2] < self.max[2]
end

--- Returns true if the specified bounding box is wholly contained
--- within these Bounds
function Bounds:contains_bounds(b)
   return self:contains(b.min) and self:contains(b.max)
end

--- Returns true if any part of the specified bounding box overlaps
--- these Bounds even a little
function Bounds:collides_bounds(b)
   for _, p in ipairs(self._points) do
      if b:contains(p) then return true end
   end
   for _, p in ipairs(b._points) do
      if self:contains(p) then return true end
   end
   return false
end
--- Translates a bounding box, returning new Bounds
function Bounds:translate(p)
   return Bounds.new(self.min:translate(p),self.max:translate(p))
end

function Bounds.fromRect(rectangle)
   return Bounds.new({ rectangle[1], rectangle[2]}, { rectangle[3], rectangle[4] })
end
