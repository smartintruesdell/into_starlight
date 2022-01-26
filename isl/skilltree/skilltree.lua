--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/scripts/util.lua")
require("/isl/isl_util.lua")
require("/isl/point.lua")
require("/isl/bounds.lua")
require("/isl/skill/skill.lua")

-- Global State ---------------------------------------------------------------
-- locale :: string
locale = ""
-- currency_table :: table<string, Currency>
currency_table = {}
-- skill_tree :: table<string, ISLSkill>
skills_graph = nil
-- grid_tile_image :: string
grid_tile_image = nil
-- grid_tile_size :: number
grid_tile_size = nil
-- canvas :: Canvas
canvas = nil
-- canvas_size :: Point
canvas_size = nil
-- canvas_bounds :: Bounds
canvas_bounds = nil
-- data :: table
data = nil
-- selected :: string
selected = nil
-- mouse_down :: boolean
mouse_down = false
-- mouse_position_last :: Point
mouse_position_last = nil
-- drag_offset :: Point
drag_offset = Point.new({0,0})

-- Functions ------------------------------------------------------------------

--- Loads skill modules for the player
--- load_skills_graph(table) -> table<string, ISLSkill>
function load_skills_graph(data)
   local graph = {}

   -- First, we'll grab all of the common modules
   for module_name, file in pairs(data.skillModules.common) do
      sb.logInfo("ISL: Loading skills module "..module_name)
      -- And zip included skills into our skill tree
      for skill_name, skill_data in pairs(root.assetJson(file)) do
         graph[skill_name] = ISLSkill.new(skill_data)
      end
   end

   -- Next, we want to merge the starting skills for the player's species
   local species_file = nil
   if data.skillModules.species[player.species()] then
      species_file = data.skillModules.species[player.species()]
      sb.logInfo("ISL: Loading species skills module for "..player.species())
   else
      -- With a default if there isn't one configured
      species_file = data.skillModules.species.default
      sb.logInfo("ISL: Loading default species skills module, "..player.species().."did not specify a skill module")
   end
   -- And zip included skills into our skill tree
   local species_module = root.assetJson(species_file)
   for skill_name, skill_data in pairs(species_module) do
      graph[skill_name] = ISLSkill.new(skill_data)
   end

   return graph
end

function set_selected_skill(select_skill_id)
   selected = select_skill_id
   for skill_id, _ in pairs(skills_graph) do
      skills_graph[skill_id].is_selected = skill_id == select_skill_id
   end

   return skills_graph
end

--- Draws the background for the skill tree
function draw_skills_graph_background()
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
function draw_skills_graph_node_lines(drag_offset, skills_graph)
   for _, skill in pairs(skills_graph) do
      for _, child_id in ipairs(skill.children) do
         assert(skills_graph[child_id], "Unable to find skill "..child_id)
         skill:draw_line_to(skills_graph[child_id], drag_offset, canvas)
      end
   end
end

--- Draws the skill tree node icons
function draw_skills_graph_node_icons(drag_offset, skills_graph)
   for _skill_name, skill in pairs(skills_graph) do
      local icon_bounds = skill:get_icon_bounds():translate(drag_offset)

      if canvas_bounds:collides_bounds(icon_bounds) then
         skill:draw(drag_offset, canvas)
      end
   end
end

--- Draws the skill tree nodes
function draw_skills_graph_nodes(drag_offset, skills_graph)
   if not skills_graph then return end

   draw_skills_graph_node_lines(drag_offset, skills_graph)
   draw_skills_graph_node_icons(drag_offset, skills_graph)
end

--- Draws the indicator to inform the player of their current
--- currency totals
function draw_skills_graph_currencies_reference()

end

--- Draws the skill tree
function draw_skills_graph()
   canvas:clear()

   draw_skills_graph_background()
   draw_skills_graph_nodes(drag_offset, skills_graph)
   draw_skills_graph_currencies_reference()
end

--- Draws the info panel
function draw_info_panel()
   if not selected then
      -- If we don't have a skill selected, we'll show instructional info
      widget.setText("title", data.strings.info.title[locale])
			widget.setText("infoPanel.text", data.strings.info.description[locale])
   else
      -- If we have a skill selected, we'll show information about that skill
      if skills_graph[selected] then
         widget.setText(
            "title",
            skills_graph[selected].strings.name[locale]
         )
         widget.setText(
            "infoPanel.text",
            skills_graph[selected].strings.description[locale]
         )
      else
         widget.setText("title", data.strings.skills.error[1])
         widget.setText("title", data.strings.skills.error[2])
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

      draw_skills_graph()
   end
end

function handle_mouse_left_click(position)
   if not skills_graph then return end

   -- SELECT the clicked node if it is in bounds
   for skill_id, skill in pairs(skills_graph) do
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
   draw_skills_graph()
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
   currency_table = root.assetJson("/currencies.config")
   data = root.assetJson("/isl/skilltree/skilltree_data.json")

   locale = data.locale or 'en_US'

   grid_tile_image = data.gridTileImage
   grid_tile_size = root.imageSize(grid_tile_image)

   -- initialize the canvas for drawing
   canvas = widget.bindCanvas("canvas")
   canvas_size = widget.getSize("canvas")
   canvas_bounds = Bounds.new({0, 0}, {canvas_size[1], canvas_size[2]})

   skills_graph = load_skills_graph(data)

   -- draw the grid
   draw_skills_graph()
end

function update(dt)
   if mouse_down then handle_mouse_drag() end
end
