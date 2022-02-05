--[[
   Rendering code for drawing the Skill Graph in the CharacterSheet UI
]]
require("/scripts/questgen/util.lua")
require("/isl/ui/uicomponent.lua")
require("/isl/colors.lua")
require("/isl/point.lua")
require("/isl/bounds.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/ui/charactersheet/components/skilltree/background/background.lua")
require("/isl/ui/charactersheet/components/skilltree/nodes/bonus_node.lua")
require("/isl/ui/charactersheet/components/skilltree/nodes/perk_node.lua")
require("/isl/ui/charactersheet/components/skilltree/nodes/species_node.lua")

-- Class ----------------------------------------------------------------------

UISkillTree = defineSubclass(UIComponent, "UISkillTree")()

-- Constructor ----------------------------------------------------------------

function UISkillTree:init(canvas_id)
   UIComponent.init(self) -- super()
   -- initialize the canvas for drawing
   self.canvas = widget.bindCanvas(canvas_id)
   assert(self.canvas, "Failed to bind SkillTree Canvas")

   if not SkillGraph then ISLSkillGraph.initialize() end

   -- Mount child components
   -- - Add the UISkillTreeBackground component
   self.background = UISkillTreeBackground.new(self.canvas)

   -- - Add a UISkillTreeNode for each skill
   self:addChildrenForSkills(SkillGraph.skills)

   -- This state object is passed to all children in the `update` event
   self.state = {
      selected_skill = nil,
      unlocked_skills = SkillGraph.unlocked_skills,
      available_skills = SkillGraph.available_skils,
      drag_offset = Point.new({
         self.canvas_size[1] * 0.5,
         self.canvas_size[2] * 0.5
      })
   }
end

function UISkillTree:addChildrenForSkills(skills_list)
   for skill_id, skill in pairs(skills_list) do
      if skill.type == "species" then
         self:addChild(skill_id, UISpeciesNode.new(skill, self.canvas))
      elseif skill.type == "perk" then
         self:addChild(skill_id, UIPerkNode.new(skill, self.canvas))
      else
         self:addChild(skill_id, UIBonusNode.new(skill, self.canvas))
      end
   end
end

-- Methods --------------------------------------------------------------------

function UISkillTree:select_skill(skill_id)
   self.state.selected_skill = skill_id
end

-- Event Handlers -------------------------------------------------------------

function UISkillTree:handleMouseEvent(position, button, pressed)
   UIComponent.handleMouseEvent(
      self,
      position,
      button,
      pressed,
      self.state
   )
end

function UISkillTree:handleMouseDrag(position, start_position)
   local motion = position:translate(start_position:inverse())

   self.state.drag_offset = self.state.drag_offset:translate(motion)

   self:draw()
end

function UISkillTree:update(dt)
   self.state.unlocked_skills = SkillGraph.unlocked_skills
   self.state.available_skills = SkillGraph.available_skills

   UIComponent:update(dt, self.state)
end

-- Render ---------------------------------------------------------------------

function UISkillTree:draw()
   self.canvas:clear()

   self.background:draw()
   self:draw_graph_lines()

   -- Draws the skill nodes
   UIComponent.draw(self, self.state)
end

function UISkillTree:draw_graph_lines()
   local LINE_TYPE = {}
   LINE_TYPE.UNAVAILABLE = 0
   LINE_TYPE.AVAILABLE = 1
   LINE_TYPE.UNLOCKED = 2

   local function sort_skill_ids(skill_1_id, skill_2_id)
      if (skill_1_id < skill_2_id) then
         return skill_1_id, skill_2_id
      end
      return skill_2_id, skill_1_id
   end

   local lines = {}

   for _, skill in pairs(SkillGraph.skills) do
      for _, child_id in ipairs(skill.children) do
         assert(SkillGraph.skills[child_id], "Unable to find skill "..child_id)

         local first_id, second_id = sort_skill_ids(skill.id, child_id)
         lines[first_id] = lines[first_id] or {}

         if SkillGraph.unlocked_skills[skill.id] then
            lines[first_id][second_id] = LINE_TYPE.UNLOCKED
         elseif SkillGraph.available_skills[skill.id] then
            if not lines[first_id][second_id] or lines[first_id][second_id] < LINE_TYPE.AVAILABLE then
               lines[first_id][second_id] = LINE_TYPE.AVAILABLE
            end
         else
            if not lines[first_id][second_id] or lines[first_id][second_id] < LINE_TYPE.UNAVAILABLE then
               lines[first_id][second_id] = LINE_TYPE.UNAVAILABLE
            end
         end
      end
   end

   for from_id, children in pairs(lines) do
      for to_id, line_type in pairs(children) do
         -- Determine line color
         local line_color, line_width = nil, nil


         if line_type == LINE_TYPE.UNLOCKED then
            line_color = Colors.get_color("line_color_unlocked")
            line_width = 3
         elseif line_type == LINE_TYPE.AVAILABLE then
            line_color = Colors.get_color("line_color_available")
            line_width = 2
         else
            line_color = Colors.get_color("line_color_default")
            line_width = 1
         end

         self.canvas:drawLine(
            SkillGraph.skills[from_id].position:translate(self.offset),
            SkillGraph.skills[to_id].position:translate(self.offset),
            line_color,
            line_width
         )
      end
   end
end
