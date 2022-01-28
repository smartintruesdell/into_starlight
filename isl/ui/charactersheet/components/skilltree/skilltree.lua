--[[
   Rendering code for drawing the Skill Graph in the CharacterSheet UI
]]
require('/isl/event_emitter.lua')
require('/isl/point.lua')
require('/isl/bounds.lua')
require('/isl/skillgraph/skillgraph.lua')

-- Constants ------------------------------------------------------------------
local PATH = '/isl/ui/charactersheet/components/skilltree'

local Widgets = {}
Widgets.Canvas = "canvas"

local Assets = {}
Assets.background_tile_image = PATH.."/assets/background_tile.png"

-- Utility Functions ----------------------------------------------------------

local function is_affordable(_ --[[skill: ISLSkill]])
   -- TODO: This needs to check price of skill against
   -- currencies, which is out of scope for this feature branch.
   return true
end

local function get_color(_ --[[color_id: string]])
   return "#FFFFFF"
end

-- Class ----------------------------------------------------------------------

SkillTreeUI = createClass("SkillTreeUI")

-- Constructor ----------------------------------------------------------------

function SkillTreeUI:init()
   -- initialize the canvas for drawing
   self.canvas = widget.bindCanvas(Widgets.Canvas)

   assert(self.canvas, "Failed to bind SkillTreeUI Canvas")

   self.canvas_size = widget.getSize(Widgets.Canvas)
   self.canvas_bounds = Bounds.new(
      {0, 0},
      self.canvas_size
   )
   self.background_tile_size = root.imageSize(Assets.background_tile_image)

   -- Store drag offset
   self.offset = Point.new({
      self.canvas_size[1] * 0.5,
      self.canvas_size[2] * 0.5
   })

   -- Mouse information
   self.mouse = {}
   self.mouse.last_position = Point.new({ 0, 0 })
   self.mouse.pressed = false

   -- Track 'selected' skill
   self.selected_skill_id = nil

   -- Add an event emitter
   self.events = EventEmitter.new()
end

-- Methods --------------------------------------------------------------------

function SkillTreeUI:select_skill(skill_id)
   self.selected_skill_id = skill_id
end

-- Event Handlers -------------------------------------------------------------

function SkillTreeUI:handle_mouse_event(position, button, pressed)
   self.mouse.pressed = pressed

   if button == 0 then
      if self.mouse.pressed then
         self:_handle_left_click(position)
      end

      self:draw()
   end

   self.events:emit('click', position, button, pressed, self)

   return self
end

function SkillTreeUI:drag()
   local position = Point.new(self.canvas:mousePosition())
   local dt = position:translate(self.mouse.last_position:inverse())

   self.offset = self.offset:translate(dt)
   self.mouse.last_position = position

   self:draw()

   self.events:emit('drag', dt, self)
end

function SkillTreeUI:update(--[[dt : number]])
   if self.mouse.pressed then self:drag() end
end

function SkillTreeUI:_handle_left_click(position)
   self.mouse.last_position = Point.new(position)

   -- Check the skills graph to find a skill that may have been clicked
   for skill_id, skill in pairs(SkillGraph.skills) do
      local skill_icon_bounds = self:_get_skill_icon_bounds(skill)
      if skill_icon_bounds:contains(position) then
         if self.selected_skill_id == skill_id then
            self:select_skill(nil)
         else
            self:select_skill(skill_id)
         end
         break
      end
   end

   self.events:emit('left_click', position, self)
end

-- Render ---------------------------------------------------------------------

function SkillTreeUI:draw()
   self.canvas:clear()

   self:_draw_background()
   self:_draw_graph_lines()
   self:_draw_graph_skills()

   self.events:emit('draw', self)

   return self
end

function SkillTreeUI:_draw_background()

   local grid_offset = Point.new({
         self.offset[1] % self.background_tile_size[1],
         self.offset[2] % self.background_tile_size[2]
   })

   self.canvas:drawTiledImage(
      Assets.background_tile_image,
      grid_offset,
      {
         0,
         0,
         self.canvas_size[1] + self.background_tile_size[1],
         self.canvas_size[2] + self.background_tile_size[2]
      }
   )
end

function SkillTreeUI:_draw_graph_lines()
   for _, skill in pairs(SkillGraph.skills) do
      for _, child_id in ipairs(skill.children) do
         assert(SkillGraph.skills[child_id], "Unable to find skill "..child_id)
         -- TODO: move drawing from Skill to this module
         skill:draw_line_to(SkillGraph.skills[child_id], self.offset, self.canvas)
      end
   end
end

function SkillTreeUI:_draw_graph_skills()
   for _, skill in pairs(SkillGraph.skills) do
      local icon_bounds = self:_get_skill_icon_bounds(skill)

      if self.canvas_bounds:collides_bounds(icon_bounds) then
         -- TODO: move drawing from Skill to this module
         self:_draw_skill(skill)
      end
   end
end

function SkillTreeUI:_draw_skill(skill)
   -- Draw the icon background
   local background_image, background_color = self:_get_skill_background(skill)

   self.canvas:drawImage(
      background_image,
      skill.position:translate(self.offset),
      1,
      background_color,
      true
   )

   -- Draw the icon, if any
   local icon_image, icon_color = self:_get_skill_icon(skill)
   if icon_image then
      self.canvas:drawImage(
         icon_image,
         skill.position:translate(self.offset),
         1,
         icon_color,
         true
      )
   end

   -- Draw the icon frame
   self.canvas:drawImage(
      skill.icon_frame.border..":"..(skill.rarity or "default"),
      skill.position:translate(self.offset),
      1,
      icon_color,
      true
   )

   if LOG_LEVEL == LOG_LEVELS.DEBUG then
      self:_debug_draw_skill_bounds(skill)
   end

   return self
end

function SkillTreeUI:_get_skill_background(skill)
   local background_image = nil
   if self.selected_skill_id == skill.id then
      background_image = skill.icon_frame.background..":selected"
   else
      background_image = skill.icon_frame.background..":default"
   end

   local background_color = nil
   if not SkillGraph.available_skills[skill.id] then
      -- If this skill is unavailable,
      background_color = get_color("background_color_unavailable")
   elseif SkillGraph.unlocked_skills[skill.id] then
      -- If this skill is already unlocked,
      background_color = get_color("background_color_unlocked")
   elseif is_affordable(skill) then
      -- If the skill is not unlocked, but could be
      background_color = get_color("background_color_available")
   else
      -- Fallback
      background_color = get_color("background_color_default")
   end

   return background_image, background_color
end

function SkillTreeUI:_get_skill_icon(skill)
   local icon_color = nil
   if not SkillGraph.available_skills[skill.id] then
      -- If this skill is unavailable,
      icon_color = get_color("icon_color_unavailable")
   elseif SkillGraph.unlocked_skills[skill.id] then
      -- If this skill is already unlocked,
      icon_color = get_color("icon_color_unlocked")
   elseif is_affordable(skill) then
      -- If the skill is not unlocked, but could be
      icon_color = get_color("icon_color_available")
   else
      -- Fallback
      icon_color = get_color("icon_color_default")
   end

   return skill.icon, icon_color
end

function SkillTreeUI:_get_skill_icon_bounds(skill)
   local icon_size = CONFIG.icon[skill.type].size * 0.5

   return Bounds.new(
      skill.position:translate(Point.new({ icon_size * -1, icon_size * -1 })),
      skill.position:translate(Point.new({ icon_size, icon_size }))
   ):translate(self.offset)
end

function SkillTreeUI:_debug_draw_skill_bounds(skill)
   local bounds = self:_get_skill_icon_bounds(skill)
   local points = {
      Point.new(bounds.min),
      Point.new({ bounds.min[1], bounds.max[2] }),
      Point.new(bounds.max),
      Point.new({ bounds.max[1], bounds.min[2] }),
   }

   self.canvas:drawLine(
      points[1],
      points[2],
      "#55FFFF",
      1
   )
   self.canvas:drawLine(
      points[2],
      points[3],
      "#55FFFF",
      1
   )
   self.canvas:drawLine(
      points[3],
      points[4],
      "#55FFFF",
      1
   )
   self.canvas:drawLine(
      points[1],
      points[4],
      "#55FFFF",
      1
   )
end
