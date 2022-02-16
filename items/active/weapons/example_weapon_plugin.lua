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
local super_new = Weapon.new
local super_init = Weapon.init
local super_update = Weapon.update

local super_plugin_update_weaponConfig =
  Weapon.plugin_update_weaponConfig or function (config) return config end

--- Updates the weaponConfig before it is used to instantiate the weapon.
--- This is where you can make changes that will impact the Weapon.new method.
--- It is a limitation of the plugin loader that we can't modify Weapon.new
--- (that's where plugins get loaded)
function Weapon.plugin_update_weaponConfig(weaponConfig)

  return super_plugin_update_weaponConfig(weaponConfig)
end

function Weapon:new(weaponConfig)
  -- Always call the `super` method with self and all appropriate arguments
  return super_new(self, weaponConfig)
end

function Weapon:init()
  -- Always call the `super` method with self and all appropriate arguments
  super_init(self)
end

function Weapon:update(dt, fireMode, shiftHeld)
  -- Always call the `super` method with self and all appropriate arguments
  return super_update(self, dt, fireMode, shiftHeld)
end
