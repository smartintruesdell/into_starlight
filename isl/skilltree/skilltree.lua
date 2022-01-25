--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/isl/isl_util.lua")

-- Constants ------------------------------------------------------------------
currency_table = {}
skill_tree = nil
grid_tile_image = nil
grid_tile_size = nil
canvas_size = nil
canvas = nil
data = nil
selected = nil
mouse_down = false
mouse_position_last = nil

-- Variables ------------------------------------------------------------------
drag_offset = { x = 0, y = 0 }

-- Functions ------------------------------------------------------------------

--- Loads skill tree modules for the player
function load_skill_tree_modules(data)
   -- First, we'll grab all of the common modules
   local temp_file = nil
   local st = {}

   for _, file in ipairs(data.commonSkillModules) do
      temp_file = root.assetJson(file)
      st = ISLUtil.MergeTable(st, temp_file)
   end

   -- Next, we want to determine the player's species
   if data.speciesSkillModules[player.species()] then
      temp_file = root.assetJson(data.speciesSkillModules[player.species()])
   else
      temp_file = root.assetJson(data.speciesSkillModules.default)
   end

   st = ISLUtil.MergeTable(
      st,
      species_file
   )

   return st
end

--- Draws the background for the skill tree
function draw_skill_tree_background()
   local grid_offset = {
      drag_offset.x % grid_tile_size[1],
      drag_offset.y % grid_tile_size[2]
   }

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
function draw_skill_tree_node_lines()
   local start_point = { 0, 0 }
   local end_point = { 0, 0 }
end

--- Draws the skill tree node icons
function draw_skill_tree_node_icons()
   local start_point = { 0, 0 }
   local end_point = { 0, 0 }
end

--- Draws the skill tree nodes
function draw_skill_tree_nodes()
   if not skill_tree then return end

   draw_skill_tree_node_lines()
   draw_skill_tree_node_icons()
end

--- Draws the indicator to inform the player of their current
--- currency totals
function draw_skill_tree_currencies_reference()

end

--- Draws the skill tree
function draw_skill_tree()
   canvas:clear()

   draw_skill_tree_background()
   draw_skill_tree_nodes()
   draw_skill_tree_currencies_reference()
end

--- Draws the info panel
function draw_info_panel()
   if not selected then
      -- If we don't have a skill selected, we'll show instructional info
      widget.setText("title", data.strings.info[1])
			widget.setText("infoList.text", data.strings.info[2])
   else
      -- If we have a skill selected, we'll show information about that skill
      if data.strings.skills[selected] then
         widget.setText("title", data.strings.skills[selected][1])
         widget.setText("infoList.text", data.strings.skills[selected][2])
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

      if not is_button_down then
         draw_skill_tree()
      else
         handle_mouse_left_click(position)
      end
   end
end

function handle_mouse_left_click(position)
   if not skill_tree then return end

   local clicked_node = nil

   -- SELECT the clicked node if it is in bounds
   for skill_node, tbl in pairs(skill_tree) do
      -- TODO: icon_size_offset should depend on whether
      -- this is a `skill` or a `perk`
      local icon_size_offset = (data.iconSizes.skill * 0.5)

      local x_range = {
         tbl.position[1] + drag_offset.x - icon_size_offset - 1,
         tbl.position[1] + drag_offset.x - icon_size_offset + 1
      }

      if position[1] > x_range[1] and position[2] < x_range[2] then
         local y_range = {
            tbl.position[2] + drag_offset.y + icon_size_offset - 1,
            tbl.position[2] + drag_offset.y + icon_size_offset + 1,
         }

         if position[2] > y_range[1] and position[2] < y_range[2] then
            clicked = skill_node
         end
         break
      end
   end
end

function handle_mouse_drag()
   local mouse_position = canvas:mousePosition()

   drag_offset.x = drag_offset.x + mouse_position[1] - mouse_position_last[1]
   drag_offset.y = drag_offset.y + mouse_position[2] - mouse_position_last[2]

   mouse_position_last = mouse_position

   draw_info_panel()
   draw_skill_tree()
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

   grid_tile_image = data.defaultGridTileImage
   grid_tile_size = root.imageSize(grid_tile_image)

   -- initialize the canvas for drawing
   canvas = widget.bindCanvas("canvas")
   canvas_size = widget.getSize("canvas")

   skill_tree = load_skill_tree_modules(data)

   -- draw the grid
   draw_skill_tree()
end

function update(dt)
   if mouse_down then handle_mouse_drag() end
end
