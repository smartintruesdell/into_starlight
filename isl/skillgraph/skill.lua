--[[
  IntoStarlight provides "Skills" as nodes on a passive skill tree that the
  user can unlock by spending "Skill Points" earned through play.

  This module defines a 'class' for reasoning about Skills in the UI and
  in the systems of the mod
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/point.lua")

-- Class ----------------------------------------------------------------------

--- Models a single IntoStarlight Skill
ISLSkill = createClass("ISLSkill")

--- Constructor
function ISLSkill:init(data)
  if data.id == "the_warrior" then
    ISLLog.debug(util.tableToString(data))
  end
  -- Safety defaults
  data = data or {}
  data.unlocks = data.unlocks or {}

  -- Id
  self.id = data.id or ''
  self.type = data.type or 'bonus'

  -- Visuals
  self.icon = data.icon
  self.background = data.background
  self.mask = data.mask

  -- Relationships
  self.position = Point.new(data.position or {0,0})
  self.children = data.children or {}

  -- Unlocks
  self.unlocks = {}
  self.unlocks.stats = data.unlocks.stats or {}
  self.unlocks.blueprints = data.unlocks.blueprints or {}
  self.unlocks.techs = data.unlocks.techs or {}
end

function ISLSkill.from_module(data)
  if data.type == "bonus" then return ISLBonusSkill.new(data) end
  if data.type == "perk" then return ISLPerkSkill.new(data) end

  return ISLSkill.new(data)
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

-- Subclasses -------------------------------------------------------------------

ISLBonusSkill = defineSubclass(ISLSkill, "ISLBonusSkill")()
ISLPerkSkill = defineSubclass(ISLSkill, "ISLPerkSkill")()

-- Bonuses ----------------------------------------------------------------------

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

  assert(self.background_type ~= nil, "Expected a valid template background for "..data.id..":"..data.bonusType)

  local stat_points = root.evalFunction(self.template.levelingFunction, self.level)
  for stat_id, proportions in pairs(self.template.statDistribution) do
    local stat_bonus = {}
    -- TODO: It probably doesn't make sense for +5 <stat> to cost the same
    -- amount of leveled stat_points as +5% <stat>. We'll have to investigate
    -- and balance this.
    stat_bonus.amount = math.floor(stat_points * proportions[1]) -- +5
    stat_bonus.multiplier = 1+(math.floor(stat_points * proportions[2]) / 100) -- +5%

    self.unlocks.stats[stat_id] = stat_bonus
  end
end

function ISLBonusSkill:transform(dt, dr, ds)
  -- NOTE: This looks like we could do ISLSkill.transform(self, ...) but
  -- that won't work because the super method returns a new ISLSkill and
  -- we don't want our BonusSkills becoming boring regular skills.
  dt = dt or { 0, 0 }
  dr = dr or 0
  ds = ds or 1

  local res = ISLBonusSkill.new(self)
  res.position = self.position:transform(dt, dr, ds)

  return res
end


-- Perks ----------------------------------------------------------------------

function ISLPerkSkill:init(data)
  ISLSkill.init(self, data)
  self.effectName = data.effectName
end

function ISLPerkSkill:transform(dt, dr, ds)
  -- NOTE: This looks like we could do ISLSkill.transform(self, ...) but
  -- that won't work because the super method returns a new ISLSkill and
  -- we don't want our PerkSkills becoming boring regular skills.
  dt = dt or { 0, 0 }
  dr = dr or 0
  ds = ds or 1

  local res = ISLPerkSkill.new(self)
  res.position = self.position:transform(dt, dr, ds)

  if res.id == "the_warrior" then
    ISLLog.debug("skill translate result: %s", util.tableToString(res))
  end

  return res
end
