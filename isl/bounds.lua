local prototype = require("/isl/prototype.lua")
local bounds_prototype = prototype{
      default = prototype.assignment_copy,
}

function bounds_prototype:contains(x, y)
   return x > self.x1 and x < self.x2 and y > self.y1 and y < self.y2
end

function bounds_prototype:offset(x_offset, y_offset)
   local b = bounds_prototype:clone()

   b.x1 = math.min(self.x1, self.x2) + x_offset
   b.x2 = math.max(self.x1, self.x2) + x_offset
   b.y1 = math.min(self.y1, self.y2) + y_offset
   b.y2 = math.max(self.y1, self.y2) + y_offset

   return b
end

function Bounds(x1, y1, x2, y2)
   local b = bounds_prototype:clone()

   b.x1 = math.min(x1, x2)
   b.x2 = math.max(x1, x2)
   b.y1 = math.min(y1, y2)
   b.y2 = math.max(y1, y2)

   return b
end
