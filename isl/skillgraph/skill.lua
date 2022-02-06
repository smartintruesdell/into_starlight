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
   -- Safety defaults
   data = data or {}
   data.strings = data.strings or {}
   data.unlocks = data.unlocks or {}

   -- Id
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

function ISLSkill.from_module(data)
   -- If the type isn't `bonus`, this is staright forward.
   if data.type ~= "bonus" then return ISLSkill.new(data) end

   -- If the type IS `bonus`, then we need to derive the skill from available
   -- templates.
   return ISLBonusSkill.new(data)
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

-- Subclass -------------------------------------------------------------------

ISLBonusSkill = defineSubclass(ISLSkill, "ISLBonusSkill")()

-- Constructor ----------------------------------------------------------------

function ISLBonusSkill:init(data)
   ISLSkill.init(self, data)
   ISLBonusSkill.templates = ISLBonusSkill.templates or root.assetJson("/isl/skillgraph/bonus_types.config")

   -- Additional "Bonus" type configuration
   assert(data.bonusType ~= nil, "Expected a valid bonus type for node "..data.id)
   self.bonusType = data.bonusType
   self.level = data.level or 1
   self.template = ISLBonusSkill.templates[self.bonusType]
   assert(self.template, "Expected a valid template for bonus skill "..data.id)
   self.background_type = self.template.backgroundType

   local stat_points = root.evalFunction(self.template.levelingFunction, self.level)
   for stat_id, multiplier in pairs(self.template.statDistribution) do
      self.unlocks.stats[stat_id] = math.floor(stat_points * multiplier)
   end
end

function ISLBonusSkill:transform(dt, dr, ds)
   dt = dt or { 0, 0 }
   dr = dr or 0
   ds = ds or 1

   local res = ISLBonusSkill.new(self)
   res.position = self.position:transform(dt, dr, ds)

   return res
end
