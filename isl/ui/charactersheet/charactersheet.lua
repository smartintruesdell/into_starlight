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

function handle_revert_button()
  ISLSkillGraph.revert()
  self.CharacterSheet:update()
end

function no_op() end

-- Init -----------------------------------------------------------------------

function init()
   -- Initialize UI components
   if not SkillGraph then ISLSkillGraph.initialize() end
   if not Strings then ISLStrings.initialize() end

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
