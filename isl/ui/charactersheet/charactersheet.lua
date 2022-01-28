--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/isl/point.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/ui/charactersheet/components/skilltree/skilltree.lua")
require("/isl/ui/charactersheet/components/playerinfo/playerinfo.lua")

-- Globals --------------------------------------------------------------------

SkillTree = nil
PlayerInfoPanel = nil

-- Event Handlers -------------------------------------------------------------

function handle_canvas_mouse_event(...)
   SkillTree:handle_mouse_event(...)
end

function handle_close_button_event()
   pane.dismiss()
end

-- Init -----------------------------------------------------------------------

function init()
   -- Initialize UI components
   SkillTree = SkillTreeUI.new()
   PlayerInfoPanel = PlayerInfoPanelUI.new()

   -- Draw
   SkillTree:draw()
   PlayerInfoPanel:draw()
end

function update(dt)
   SkillTree:update(dt)
   PlayerInfoPanel:update()
end
