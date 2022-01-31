--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/strings.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/ui/charactersheet/components/skilltree/skilltree.lua")
require("/isl/ui/charactersheet/components/playerinfo/playerinfo.lua")
require("/isl/ui/charactersheet/components/portrait/portrait.lua")

-- Globals --------------------------------------------------------------------

SkillTree = nil
PlayerInfoPanel = nil
PlayerPortrait = nil
PlayerBodyPortrait = nil

-- Event Handlers -------------------------------------------------------------

function handle_canvas_mouse_event(...)
   SkillTree:handle_mouse_event(...)
end

function closeButton()
   pane.dismiss()
end

-- Init -----------------------------------------------------------------------

function init()
   -- Initialize UI components
   if not SkillGraph then ISLSkillGraph.initialize() end
   if not Strings then initialize_Strings() end

   SkillTree = SkillTreeUI.new()
   PlayerInfoPanel = PlayerInfoPanelUI.new()
   PlayerPortrait = UIPortrait.new("portrait", "bust")
   PlayerBodyPortrait = UIPortrait.new("portraitFull", "full", true)

   -- Draw
   SkillTree:draw()
   PlayerInfoPanel:draw()
   PlayerPortrait:draw()
   PlayerBodyPortrait:draw()
end

function update(dt)
   SkillTree:update(dt)
   PlayerInfoPanel:update()
   PlayerPortrait:update()
   PlayerBodyPortrait:draw()
end
