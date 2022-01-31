--[[
   Stats display subcomponent for the Character Sheet
]]

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/log.lua")
require("/isl/util.lua")
require("/isl/strings.lua")
require("/isl/ui/uicomponent.lua")

-- Class ----------------------------------------------------------------------

UICharacterSheetStats = defineSubclass(UIComponent, "UICharacterSheetStats")()

-- Constructor ----------------------------------------------------------------

function UICharacterSheetStats:init()

end

function UICharacterSheetStats:createTooltip(mouse_position)


   self:createTooltipsForChildren(mouse_position)
end
