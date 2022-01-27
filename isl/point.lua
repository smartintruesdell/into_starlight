--[[
   Abstraction over x,y coordinates to simplify* reasoning
]]
require("/scripts/questgen/util.lua")

--- Models a 2d point
Point = createClass("Point")

--- Point constructor
function Point:init(p)
   self[1] = p[1] or 0
   self[2] = p[2] or 0
end

--- Inverts a point by reversing then signs of its coordinates
function Point:invert()
   return Point.new(
      {
         self[1] * -1,
         self[2] * -1
      }
   )
end

function Point:transform(dt, dr, ds)
   dt = dt or { 0, 0 }
   dr = dr or 0
   ds = ds or 1

   return self:scale(ds):rotate(dr):translate(dt)
end

--- Translates a point along x, y axes
function Point:translate(p)
   return Point.new(
      {
         self[1] + p[1],
         self[2] + p[2]
      }
   )
end

--- Rotates the point by some number of degrees relative to the
--- origin
function Point:rotate(deg)
   return Point.new(
      {
         (self[1] * math.cos(deg)) - (self[2] * math.sin(deg)),
         (self[2] * math.cos(deg)) + (self[1] * math.sin(deg))
      }
   )
end

--- Rotates the point by some number of degrees relative to
--- a provided reference point
function Point:rotate_relative_to(deg, ref)
   return self:translate(ref:invert()):rotate(deg):translate(ref)
end

--- Scales a point's coordinates relative to the origin
function Point:scale(ds)
   ds = ds or 1

   return Point.new({
         self[1] * ds,
         self[2] * ds
   })
end
