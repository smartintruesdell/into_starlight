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

--- Translates a point along x, y axes
function Point:translate(p)
   return Point.new(
      {
         self[1] + p[1],
         self[2] + p[2]
      }
   )
end
