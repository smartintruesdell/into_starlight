--[[
   IntoStarlight provides "Skills" as nodes on a passive skill tree that the
   user can unlock by spending "Skill Points" earned through play.

   This module defines a 'class' for reasoning about Skills in the UI and
   in the systems of the mod
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/point.lua")
require("/isl/bounds.lua")
require("/isl/log.lua")

-- Configuration --------------------------------------------------------------

-- if enabled, turns on useful debugging tools
CONFIG = nil

local function init()
   CONFIG = root.assetJson("/isl/skill/skill.config")
end

-- Class ----------------------------------------------------------------------

--- Models a single IntoStarlight Skill
ISLSkill = createClass("ISLSkill")

--- Constructor
function ISLSkill:init(data)
   if not CONFIG then init() end
   self.id = data.id or ''
   self.type = data.type or CONFIG.type.skill
   self.rarity = data.rarity or CONFIG.rarity.common
   self.strings = data.strings or CONFIG.defaultStrings
   self.icon = data.icon
   self.icon_frame = data.iconFrame or CONFIG.icon[data.type]
   self.position = Point.new(data.position or {0,0})
   self.children = data.children or {}
   self.stats = data.stats or {}
   self.effects = data.effects or {}
   self.blueprints = data.blueprints or {}
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
