--[[
  The IntoStarlight primary interface item for users without StardustLib
]]

--- Called when the user activates the item
function activate(fireMode, _shiftHeld)
	activeItem.interact("ScriptPane", "/isl/constellation/constellation.config")
  animator.playSound("activate")
end


function update()
	if mcontroller.crouching() then
		activeItem.setArmAngle(-0.15)
	else
		activeItem.setArmAngle(-0.5)
	end
end
