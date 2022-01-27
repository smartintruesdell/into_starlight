--[[
   IntoStarlight provides "Skills" as nodes on a passive skill tree that the
   user can unlock by spending "Skill Points" earned through play.

   This module defines a 'class' for reasoning about Skills in the UI and
   in the systems of the mod
]]
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

local function get_color(name)
   local aliased_color = CONFIG.colorAlias[name] or "white"

   return CONFIG.color[aliased_color]
end

-- Class ----------------------------------------------------------------------

--- Models a single IntoStarlight Skill
ISLSkill = createClass("ISLSkill")

--- Constructor
function ISLSkill:init(data)
   if not CONFIG then init() end
   self.type = data.type or CONFIG.type.skill
   self.rarity = data.rarity or CONFIG.rarity.common
   self.strings = data.strings or CONFIG.defaultStrings
   self.icon = data.icon
   self.icon_frame = data.iconFrame or CONFIG.icon[data.type]
   self.position = Point.new(data.position or {0,0})
   self.children = data.children or {}

   -- `true` if the player currently has this skill selected in the UI
   self.is_selected = data.is_selected or false
   -- `true` if the player has necessary prerequisites
   self.is_available = data.is_available or false
   -- `true` if the player has purchased this skill
   self.is_unlocked = data.unlocked or false

   -- `true` if this skill is otherwise hidden from the tree
   self.hidden = data.hidden or false
end

-- Methods --------------------------------------------------------------------

function ISLSkill:transform(dt, dr, ds)
   dt = dt or { 0, 0 }
   dr = dr or 0
   ds = ds or 1

   self.position = self.position:transform(dt, dr, ds)

   return self
end

--- Returns bounds for use in computing icon position
--- ISLSkill:draw() -> Bounds
function ISLSkill:get_icon_bounds()
   local icon_size = CONFIG.icon[self.type].size * 0.5

   return Bounds.new(
      self.position:translate(Point.new({ icon_size * -1, icon_size * -1 })),
      self.position:translate(Point.new({ icon_size, icon_size }))
   )
end

--- Returns background image, color data for drawing
--- ISLSkill:get_background() -> { string, string }
function ISLSkill:get_background()

   local background_image = nil
   if self.is_selected then
      background_image = self.icon_frame.background..":selected"
   else
      background_image = self.icon_frame.background..":default"
   end

   local background_color = nil
   if not self.is_available then
      -- If this skill is unavailable,
      background_color = get_color("background_color_unavailable")
   elseif self.is_unlocked then
      -- If this skill is already unlocked,
      background_color = get_color("background_color_unlocked")
   elseif self.is_affordable then
      -- If the skill is not unlocked, but could be
      background_color = get_color("background_color_available")
   else
      -- Fallback
      background_color = get_color("background_color_default")
   end

   return background_image, background_color
end

--- Returns icon image, color data for drawing
--- ISLSkill:get_icon() -> { string, string }
function ISLSkill:get_icon()
   local icon_color = nil
   if not self.is_available then
      -- If this skill is unavailable,
      icon_color = get_color("icon_color_unavailable")
   elseif self.is_unlocked then
      -- If this skill is already unlocked,
      icon_color = get_color("icon_color_unlocked")
   elseif self.is_affordable then
      -- If the skill is not unlocked, but could be
      icon_color = get_color("icon_color_available")
   else
      -- Fallback
      icon_color = get_color("icon_color_default")
   end

   return self.icon, icon_color
end

--- Renders the skill icon to the provided canvas
--- ISLSkill:draw(Point, Canvas) -> ISLSkill
function ISLSkill:draw(offset, canvas)
   if self.hidden then return end

   -- Draw the icon background
   local background_image, background_color = self:get_background()

   canvas:drawImage(
      background_image,
      self.position:translate(offset),
      1,
      background_color,
      true
   )
   -- Draw the icon, if any
   local icon_image, icon_color = self:get_icon()
   if icon_image then
      canvas:drawImage(
         icon_image,
         self.position:translate(offset),
         1,
         icon_color,
         true
      )
   end
   -- Draw the icon frame
   canvas:drawImage(
      self.icon_frame.border..":"..(self.rarity or "default"),
      self.position:translate(offset),
      1,
      icon_color,
      true
   )

   if LOG_LEVEL == LOG_LEVELS.DEBUG then self:draw_bounds(offset, canvas) end

   return self
end

function ISLSkill:draw_bounds(offset, canvas)
   local bounds = self:get_icon_bounds():translate(offset)
   local points = {
      Point.new(bounds.min),
      Point.new({ bounds.min[1], bounds.max[2] }),
      Point.new(bounds.max),
      Point.new({ bounds.max[1], bounds.min[2] }),
   }

   canvas:drawLine(
      points[1],
      points[2],
      "#55FFFF",
      1
   )
   canvas:drawLine(
      points[2],
      points[3],
      "#55FFFF",
      1
   )
   canvas:drawLine(
      points[3],
      points[4],
      "#55FFFF",
      1
   )
   canvas:drawLine(
      points[1],
      points[4],
      "#55FFFF",
      1
   )
end

--- Renders a line between two skill positions to the provided canvas
--- ISLSkill:draw_line_to(ISLSkill, Point, Canvas) -> ISLSkill
function ISLSkill:draw_line_to(child_skill, offset, canvas)
   -- Don't connect hidden nodes
   if self.hidden or child_skill.hidden then return end

   -- Determine line color
   local line_color = nil

   if child_skill.is_available then
      line_color = get_color("line_color_available")
   elseif self.is_unlocked and child_skill.is_unlocked then
      line_color = get_color("line_color_unlocked")
   else
      line_color = get_color("line_color_default")
   end

   canvas:drawLine(
      self.position:translate(offset),
      child_skill.position:translate(offset),
      line_color,
      CONFIG.line.width
   )

   return self
end
