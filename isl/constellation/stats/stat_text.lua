--[[
  Stats display subcomponent for the Character Sheet
]]

require "/scripts/util.lua"
require "/scripts/questgen/util.lua"
require "/isl/lib/point.lua"
require "/isl/skillgraph/skillgraph.lua"
require "/isl/lib/uicomponent.lua"

-- Class ----------------------------------------------------------------------

UIConstellationStatText = defineSubclass(UIComponent, "UIConstellationStatText")()

-- Constructor ----------------------------------------------------------------

function UIConstellationStatText:init(
    stat_name,
    is_right_aligned,
    layout_prefix,
    rollup_bonus
)
  UIComponent.init(self) -- super()

  self.stat_name = stat_name
  self.is_right_aligned = is_right_aligned
  self.layout_prefix = layout_prefix or ""
  self.rollup_bonus = rollup_bonus
end

function UIConstellationStatText:draw()
  UIComponent.draw(self)

  local long_widget_path = self.layout_prefix.."."..self.stat_name
  local amount_widget_id = long_widget_path.."Amount"

  local bonus_widget_id = long_widget_path.."BonusAmount"
  local amount = math.floor(status.stat(self.stat_name) or 0)
  -- TODO: From equipment?
  local bonus_amount = 0

  if self.rollup_bonus then
    amount = amount + bonus_amount
  end

  -- First, set the text widgets to show the correct amounts
  widget.setText(amount_widget_id, ""..(amount or "--"))

  if not self.rollup_bonus then
    if bonus_amount == 0 then
      widget.setVisible(bonus_widget_id, false)
    else
      widget.setText(bonus_widget_id, "^orange;(+"..bonus_amount..")^reset;")

      -- Next, we want to align the "bonus" widget relative to the actual size
      -- of the rendered "amount" widget so that they don't overlap
      local amount_pos = Point.new(widget.getPosition(amount_widget_id))
      local amount_width = widget.getSize(amount_widget_id)[1]
      local padding = 3
      local new_x =
        (self.is_right_aligned and -1 or 1) * (amount_width + padding)

      widget.setPosition(
        bonus_widget_id,
        amount_pos:translate({ new_x, 0 })
      )
    end
  end
end

function UIConstellationStatText:update(dt)
  UIComponent.update(self, dt)
  self:draw()
end
