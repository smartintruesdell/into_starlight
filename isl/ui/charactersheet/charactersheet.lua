--[[
   Interface logic for the IntoStarlight Skilltree
   Based in part on the Frackin' Universe researchTree
]]
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/point.lua")
require("/isl/constants/strings.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/ui/uicomponent.lua")
require("/isl/ui/skilltree/skilltree.lua")
require("/isl/ui/charactersheet/header/header.lua")
require("/isl/ui/charactersheet/stats/stats.lua")

-- Class --------------------------------------------------------------------

UICharacterSheet = defineSubclass(UIComponent, "CharacterSheet")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheet:init()
   UIComponent.init(self) -- super()

   -- Info Panel Components
   self:addChild("header", UICharacterSheetHeader.new("headerLayout"))
   self:addChild(
      "primaryStats",
      UICharacterSheetStats.new("primaryStatsLayout")
   )

   -- Skill Tree Components
   self:addChild("skill_tree", UISkillTree.new("canvas"))
end

-- Event Handlers -------------------------------------------------------------

function handle_canvas_mouse_event(...)
   self.CharacterSheet:handleMouseEvent(...)
end

function closeButton()
   pane.dismiss()
end

function strengthButton()
   --return self.CharacterSheet:handleWidgetClicked("strengthButton")
end

function precisionButton()
   --return self.CharacterSheet:handleWidgetClicked("precisionButton")
end

function witsButton()
   --return self.CharacterSheet:handleWidgetClicked("witsButton")
end

function healthButton()
   --return self.CharacterSheet:handleWidgetClicked("healthButton")
end

function defenseButton()
   --return self.CharacterSheet:handleWidgetClicked("defenseButton")
end

function evasionButton()
   --return self.CharacterSheet:handleWidgetClicked("evasionButton")
end

function energyButton()
   --return self.CharacterSheet:handleWidgetClicked("energyButton")
end

function mobilityButton()
   --return self.CharacterSheet:handleWidgetClicked("mobilityButton")
end


-- Init -----------------------------------------------------------------------

function init()
   -- Initialize UI components
   if not SkillGraph then ISLSkillGraph.initialize() end
   if not Strings then Strings.init() end

   self.CharacterSheet = UICharacterSheet.new()

   -- Draw
   self.CharacterSheet:draw()
end

function update(dt)
   self.CharacterSheet:update(dt)
end

function createTooltip(mouse_position)
   return self.CharacterSheet:createTooltip(Point.new(mouse_position))
end
