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
function Point:inverse()
   return Point.new(
      {
         self[1] * -1,
         self[2] * -1
      }
   )
end

--- Forces a point into positive coordinates
function Point:abs()
   return Point.new(
      {
         math.abs(self[1]),
         math.abs(self[2])
      }
   )
end

--- Determines the distance from the origin for this point
function Point:mag()
   return math.sqrt(math.abs(self[1])^2 + math.abs(self[2])^2)
end

function Point:transform(dt, dr, ds)
   dt = dt or { 0, 0 }
   dr = dr or 0
   ds = ds or 1

   return self:scale(ds):rotate(dr):translate(dt)
end

--- Translates a point along x, y axes
function Point:translate(dt)
   dt = dt or Point.new({ 0, 0 })

   return Point.new(
      {
         self[1] + dt[1],
         self[2] + dt[2]
      }
   )
end

--- Rotates the point by some number of degrees relative to the
--- origin
function Point:rotate(deg)
   -- Question: WHY DOES LUA's MATH LIBRARY ASSUME RADIANS?
   -- Question: WHY IS LUA LEFT HANDED
   rad = math.rad(deg or 0.0)

   -- Rounds negative numbers up, positive numbers down
   -- Did you know that math.floor(-0.02) is -1?
   local function safe_round(n)
      if n < 0 then
         return math.ceil(n)
      else
         return math.floor(n)
      end
   end

   return Point.new(
      {
         safe_round((self[1] * math.cos(rad)) - (self[2] * math.sin(rad))),
         safe_round((self[2] * math.cos(rad)) + (self[1] * math.sin(rad)))
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

function Point:equals(p2)
   return (self[1] == p2[1]) and (self[2] == p2[2])
end
