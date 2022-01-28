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

-- Class ----------------------------------------------------------------------

SkillTreeUI = createClass("SkillTreeUI")

-- Constructor ----------------------------------------------------------------

function SkillTreeUI:init()
   -- initialize the canvas for drawing
   self.canvas = widget.bindCanvas(Widgets.Canvas)
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
   self.mouse.last_position = nil
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
   self.mouse.last_position = position

   -- Check the skills graph to find a skill that may have been clicked
   for skill_id, skill in pairs(SkillGraph.skills) do
      -- TODO: icon_size_offset should depend on whether
      -- this is a `skill` or a `perk`
      if skill:get_icon_bounds():translate(self.offset):contains(position) then
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
   self.canvas.clear()

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
      local icon_bounds = skill:get_icon_bounds():translate(self.offset)

      if self.canvas_bounds:collides_bounds(icon_bounds) then
         -- TODO: move drawing from Skill to this module
         skill:draw(self.offset, self.canvas)
      end
   end
end

-- Local Functions --------------------------------------------------------------
