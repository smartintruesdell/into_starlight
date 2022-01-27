--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/scripts/util.lua")
require("/isl/point.lua")
require("/isl/bounds.lua")
require("/isl/skill/skill.lua")
require("/isl/skillgraph/skillgraph.lua")

-- Global State ---------------------------------------------------------------
-- locale :: string
local locale = ""
-- currency_table :: table<string, Currency>
local currency_table = {}
-- skill_tree :: table<string, ISLSkill>
local skill_graph = nil
-- grid_tile_image :: string
local grid_tile_image = nil
-- grid_tile_size :: number
local grid_tile_size = nil
-- canvas :: Canvas
local canvas = nil
-- canvas_size :: Point
local canvas_size = nil
-- canvas_bounds :: Bounds
local canvas_bounds = nil
-- strings :: table<string, LocalizableString>
local strings = nil
-- selected :: string
local selected = nil
-- mouse_down :: boolean
local mouse_down = false
-- mouse_position_last :: Point
local mouse_position_last = nil
-- drag_offset :: Point
local drag_offset = Point.new({0,0})

-- Functions ------------------------------------------------------------------

--- Calls SkillGraph:draw() with the correct context bindings
function draw_skill_graph()
   skill_graph.draw(canvas, canvas_bounds, drag_offset)
end

function set_selected_skill(select_skill_id)
   selected = select_skill_id
   for skill_id, _ in pairs(skill_graph) do
      skill_graph[skill_id].is_selected = skill_id == select_skill_id
   end

   return skill_graph
end

--- Draws the background for the skill tree
function draw_skill_graph_background()
   local grid_offset = Point.new({
      drag_offset[1] % grid_tile_size[1],
      drag_offset[2] % grid_tile_size[2]
   })

   canvas:drawTiledImage(
      grid_tile_image,
      grid_offset,
      {
         0,
         0,
         canvas_size[1] + grid_tile_size[1],
         canvas_size[2] + grid_tile_size[2]
      }
   )
end

--- Draws the lines connecting the skill tree nodes
function draw_skill_graph_node_lines(drag_offset, skill_graph)
   for _, skill in pairs(skill_graph) do
      for _, child_id in ipairs(skill.children) do
         assert(skill_graph[child_id], "Unable to find skill "..child_id)
         skill:draw_line_to(skill_graph[child_id], drag_offset, canvas)
      end
   end
end

--- Draws the skill tree node icons
function draw_skill_graph_node_icons(drag_offset, skill_graph)
   for _skill_name, skill in pairs(skill_graph) do
      local icon_bounds = skill:get_icon_bounds():translate(drag_offset)

      if canvas_bounds:collides_bounds(icon_bounds) then
         skill:draw(drag_offset, canvas)
      end
   end
end

--- Draws the skill tree nodes
function draw_skill_graph_nodes(drag_offset, skill_graph)
   if not skill_graph then return end

   draw_skill_graph_node_lines(drag_offset, skill_graph)
   draw_skill_graph_node_icons(drag_offset, skill_graph)
end

--- Draws the indicator to inform the player of their current
--- currency totals
function draw_skill_graph_currencies_reference()

end

--- Draws the skill tree
function draw_skill_graph()
   canvas:clear()

   draw_skill_graph_background()
   draw_skill_graph_nodes(drag_offset, skill_graph)
   draw_skill_graph_currencies_reference()
end

--- Draws the info panel
function draw_info_panel()
   if not selected then
      -- If we don't have a skill selected, we'll show instructional info
      widget.setText("title", strings.info.title[locale])
			widget.setText("infoPanel.text", strings.info.description[locale])
   else
      -- If we have a skill selected, we'll show information about that skill
      if skill_graph[selected] then
         widget.setText(
            "title",
            skill_graph[selected].strings.name[locale]
         )
         widget.setText(
            "infoPanel.text",
            skill_graph[selected].strings.description[locale]
         )
      else
         -- TODO (handle errors?)
         widget.setText("title", "Bonk")
         widget.setText("infoPanel.text", "^orange;Something Went Wrong^&reset;")
      end
   end
end

-- Event Handlers -------------------------------------------------------------

function handle_canvas_clicked(position, button, is_button_down)
   if button == 0 then
      mouse_down = is_button_down
      mouse_position_last = position

      if is_button_down then
         handle_mouse_left_click(position)
      end

      draw_skill_graph()
   end
end

function handle_mouse_left_click(position)
   if not skill_graph then return end

   -- SELECT the clicked node if it is in bounds
   for skill_id, skill in pairs(skill_graph) do
      -- TODO: icon_size_offset should depend on whether
      -- this is a `skill` or a `perk`
      if skill:get_icon_bounds():translate(drag_offset):contains(position) then
         if selected == skill_id then
            set_selected_skill(nil)
         else
            set_selected_skill(skill_id)
         end
         break
      end
   end
end

function handle_mouse_drag()
   local mouse_position = canvas:mousePosition()

   drag_offset[1] = drag_offset[1] + mouse_position[1] - mouse_position_last[1]
   drag_offset[2] = drag_offset[2] + mouse_position[2] - mouse_position_last[2]

   mouse_position_last = mouse_position

   draw_info_panel()
   draw_skill_graph()
end

function closeButton()
   handle_close_button_clicked()
end

function handle_close_button_clicked()
   pane.dismiss()
end

-- Main -----------------------------------------------------------------------

function init()
   -- load data
   local config = root.assetJson("/isl/ui/skilltree/skilltree.config.json")
   strings = root.assetJson("/isl/ui/skilltree/skilltree.strings.json")

   locale = config.locale or 'en_US'

   grid_tile_image = config.gridTileImage
   grid_tile_size = root.imageSize(grid_tile_image)

   -- initialize the canvas for drawing
   canvas = widget.bindCanvas("canvas")
   canvas_size = widget.getSize("canvas")
   canvas_bounds = Bounds.new({0, 0}, {canvas_size[1], canvas_size[2]})

   skill_graph = SkillGraph.load(config.graphPath)

   -- draw the grid
   draw_skill_graph()
   draw_info_panel()
end

function update(dt)
   if mouse_down then handle_mouse_drag() end
end
