--[[
  This is an example weapon plugin. You can use this as a template for your own
  plugins.
]]

-- First, we localize references to the existing Weapon methods.
-- These will be chains of all other plugin Weapon methods and the original Weapon
-- script methods. Note we use the Weapon.method and not Weapon:method forms because
-- we want to pass references directly
--
-- You can omit any of these that you don't plan to modify. If you're not going
-- to override uninit, you don't have to bind a super.
local super_init = Weapon.init
local super_update = Weapon.update

sb.logInfo("Plugin was evaluated!")

function Weapon:init()
  sb.logInfo("Plugin Init was called!")
  -- Always call the `super` method with all appropriate arguments
  super_init(self)
end

function Weapon:update(dt, fireMode, shiftHeld)
  sb.logInfo("Plugin Update was called!")
  -- Always call the `super` method with all appropriate arguments
  return super_update(self, dt, fireMode, shiftHeld)
end
