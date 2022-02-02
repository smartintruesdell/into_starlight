--[[
   A utility for reasoning about what the player is currently holding.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Class ----------------------------------------------------------------------

ISLHeldItemDetails = createClass("ISLHeldItemDetails")

-- Constructor ----------------------------------------------------------------

function ISLHeldItemDetails:init(entity_id)
   self._error = nil
   self.entity_id = entity_id
   self.primary = nil
   self.alt = nil

   self:update()
end

-- Methods --------------------------------------------------------------------
function ISLHeldItemDetails:update(--[[dt: number]])
   if self._error then return end
   local held_primary_item_identifier =
      world.entityHandItem(self.entity_id, "primary")
   local held_alt_item_identifier =
      world.entityHandItem(self.entity_id, "alt")

   -- Check primary item for update
   if not self.primary or self.primary.itemName ~= held_primary_item_identifier then
      ISLLog.debug("Found a new primary item, '%s'", held_primary_item_identifier)
      local err, new_primary = pcall(root.itemConfig, held_primary_item_identifier)

      if err then
         self._error = err
         return
      end

      self.primary = new_primary
   end
   -- Check alt item for update
   if not self.alt or self.alt.itemName ~= held_alt_item_identifier then
      ISLLog.debug("Found a new alt item, '%s'", held_alt_item_identifier)
      local err, new_alt = pcall(root.itemConfig, held_alt_item_identifier)

      if err then
         self._error = err
         return
      end

      self.alt = new_alt
   end
end
