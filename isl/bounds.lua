--[[
   Abstraction over two-Point "bounds" used for collision detection
   and layout
]]
require("/scripts/questgen/util.lua")
require("point.lua")

--- Models a 2d bounding box
Bounds = createClass("Bounds")

--- Bounds constructor
function Bounds:init(p1, p2)
   self.min = Point.new(math.min(p1[1], p2[1]), math.min(p1[2], p2[2]))
   self.max = Point.new(math.max(p1[1], p2[1]), math.max(p1[2], p2[2]))
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

--- Translates a bounding box, returning new Bounds
function Bounds:translate(p)
   return Bounds.new(self.min:translate(p),self.max:translate(p))
end
