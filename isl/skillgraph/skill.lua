--[[
   IntoStarlight provides "Skills" as nodes on a passive skill tree that the
   user can unlock by spending "Skill Points" earned through play.

   This module defines a 'class' for reasoning about Skills in the UI and
   in the systems of the mod
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/point.lua")

-- Class ----------------------------------------------------------------------

--- Models a single IntoStarlight Skill
ISLSkill = createClass("ISLSkill")

--- Constructor
function ISLSkill:init(data)
   self.id = data.id or ''
   self.type = data.type or 'bonus'

   -- Visuals
   self.strings = {}
   self.strings.name = data.strings.name or "Missing Skill Name"
   self.strings.description = data.strings.description or nil
   self.icon = data.icon
   self.background = data.background
   self.mask = data.mask

   -- Relationships
   self.position = Point.new(data.position or {0,0})
   self.children = data.children or {}

   -- Unlocks
   self.unlocks = {}
   self.unlocks.stats = data.unlocks.stats or {}
   self.unlocks.effects = data.unlocks.effects or {}
   self.unlocks.blueprints = data.unlocks.blueprints or {}
   self.unlocks.techs = data.unlocks.techs or {}
end

-- Methods --------------------------------------------------------------------

function ISLSkill:transform(dt, dr, ds)
   dt = dt or { 0, 0 }
   dr = dr or 0
   ds = ds or 1

   local res = ISLSkill.new(self)
   res.position = self.position:transform(dt, dr, ds)

   return res
end
