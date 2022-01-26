--[[
   IntoStarlight provides "Skills" as nodes on a passive skill tree that the
   user can unlock by spending "Skill Points" earned through play.

   This module defines a 'class' for reasoning about Skills in the UI and
   in the systems of the mod
]]
require("/scripts/questgen/util.lua")
require("/isl/point.lua")
require("/isl/bounds.lua")

-- Configuration --------------------------------------------------------------

CONFIG = root.assetJson("/isl/skill/skill.config")

local function get_color(name)
   local aliased_color = CONFIG.colorAlias[name] or "white"

   return CONFIG.color[aliased_color]
end

-- Class ----------------------------------------------------------------------

--- Models a single IntoStarlight Skill
ISLSkill = createClass("ISLSkill")

--- Constructor
function ISLSkill:init(data)
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

--- Returns bounds for use in computing icon position
--- ISLSkill:draw() -> Bounds
function ISLSkill:get_icon_bounds()
   local icon_size = CONFIG.icon[self.type].size * 0.5

   return Bounds(
      self.position:translate(Point.new({ icon_size * -1, icon_size * -1 }))
      self.position:translate(Point.new({ icon_size, icon_size }))
   )
end

--- Returns background image, color data for drawing
--- ISLSkill:get_background() -> { string, string }
function ISLSkill:get_background()
   local background_image = (
      self.icon_background or CONFIG.background[self.type].default
   )..(self.selected and ":selected" or ":default")

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

   return { background_image, background_color }
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

   return { self.icon, icon_color }
end

--- Renders the skill icon to the provided canvas
--- ISLSkill:draw(Point, Canvas) -> ISLSkill
function ISLSkill:draw(offset, canvas)
   if self.hidden then return end

   local bounds = self:get_icon_bounds():translate(offset)

   -- Draw the icon background
   local background_image, background_color = self:get_background()
   canvas:drawImage(
      background_image,
      bounds.min,
      1,
      background_color,
      false
   )
   -- Draw the icon, if any
   local icon_image, icon_color = self:get_icon()
   if icon_image then
      canvas:drawImage(
         icon_image,
         bounds.min,
         1,
         icon_color,
         false
      )
   end
   -- Draw the icon frame
   canvas:drawImage(
      self.icon_frame.border..":"..(self.rarity or "default"),
      bounds.min,
      1,
      icon_color,
      false
   )

   return self
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
