--[[
   Stats display subcomponent for the Character Sheet
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/point.lua")
require("/isl/util.lua")
require("/isl/skillgraph/skillgraph.lua")
require("/isl/ui/uicomponent.lua")

-- Class ----------------------------------------------------------------------

UICharacterSheetStatText = defineSubclass(UIComponent, "UICharacterSheetStatText")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheetStatText:init(stat_name, is_right_aligned, layout_prefix)
   self.stat_name = stat_name
   self.is_right_aligned = is_right_aligned
   self.layout_prefix = layout_prefix or ""
end

function UICharacterSheetStatText:draw()
   local amount_widget_id = self.layout_prefix.."."..self.stat_name.."Amount"
   local bonus_widget_id = self.layout_prefix.."."..self.stat_name.."BonusAmount"
   local amount = SkillGraph.stats[self.stat_name][1]
   local bonus_amount = SkillGraph.stats[self.stat_name][2]

   widget.setText(amount_widget_id, ""..(amount or "--"))
   widget.setText(bonus_widget_id, "^orange;(+"..bonus_amount..")^reset;")

   local amount_pos = Point.new(widget.getPosition(amount_widget_id))
   local amount_width = widget.getSize(amount_widget_id)[1]
   local padding = 3
   local new_x = (self.is_right_aligned and 1 or -1) * (amount_width + padding)

   widget.setPosition(
      bonus_widget_id,
      amount_pos:translate({ new_x, 0 })
   )
end
