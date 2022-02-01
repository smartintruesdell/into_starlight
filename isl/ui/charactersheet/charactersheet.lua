--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/strings.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/ui/uicomponent.lua")
require("/isl/ui/charactersheet/components/skilltree/skilltree.lua")
require("/isl/ui/charactersheet/components/header/header.lua")
require("/isl/ui/charactersheet/components/stats/stats.lua")

-- Globals --------------------------------------------------------------------

UICharacterSheet = defineSubclass(UIComponent, "CharacterSheet")()

function UICharacterSheet:init()
   self.children = {}
end

-- function UICharacterSheet:createTooltip(mouse_position)
--    self:createTooltipsForChildren(mouse_position)
-- end

CharacterSheet = nil

-- Event Handlers -------------------------------------------------------------

function handle_canvas_mouse_event(mouse_position, button, is_down)
   CharacterSheet:handleMouseEvent(mouse_position, button, is_down)
end

function closeButton()
   pane.dismiss()
end

function strengthButton()
   return CharacterSheet:handleWidgetClicked("strengthButton")
end

function precisionButton()
   return CharacterSheet:handleWidgetClicked("precisionButton")
end

function witsButton()
   return CharacterSheet:handleWidgetClicked("witsButton")
end

function healthButton()
   return CharacterSheet:handleWidgetClicked("healthButton")
end

function defenseButton()
   return CharacterSheet:handleWidgetClicked("defenseButton")
end

function evasionButton()
   return CharacterSheet:handleWidgetClicked("evasionButton")
end

function energyButton()
   return CharacterSheet.children.stats:handleWidgetClicked("energyButton")
end

function mobilityButton()
   return CharacterSheet.children.stats:handleWidgetClicked("mobilityButton")
end


-- Init -----------------------------------------------------------------------

function init()
   -- Initialize UI components
   if not SkillGraph then ISLSkillGraph.initialize() end
   if not Strings.ready then Strings.init() end

   CharacterSheet = UICharacterSheet.new()
   -- Info Panel Components
   CharacterSheet:addChild("header", UICharacterSheetHeader.new("headerLayout"))
   CharacterSheet:addChild(
      "primaryStats",
      UICharacterSheetStats.new("primaryStatsLayout")
   )

   -- Skill Tree Components
   CharacterSheet:addChild("skill_tree", UISkillTree.new("canvas"))

   -- Draw
   CharacterSheet:draw()
end

function update(dt)
   CharacterSheet:update(dt)
end

function createTooltip(mouse_position)
   return CharacterSheet:createTooltip(Point.new(mouse_position))
end
