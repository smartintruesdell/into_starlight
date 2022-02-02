--[[
   A utility for reasoning about what the player is currently holding.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")

-- Class ----------------------------------------------------------------------

ISLHeldItemsManager = createClass("ISLHeldItemDetails")

-- Constructor ----------------------------------------------------------------

function ISLHeldItemsManager:init(entity_id)
   self.entity_id = entity_id
   self.changed = false

   self.primary = nil
   self.alt = nil

   self:update()
end

-- Methods --------------------------------------------------------------------
function ISLHeldItemsManager:update(--[[dt: number]])
   self.changed = false
   self:update_held_item('primary', world.entityHandItem(self.entity_id, "primary"))
   self:update_held_item('alt', world.entityHandItem(self.entity_id, "alt"))

   return self.changed
end

function ISLHeldItemsManager:update_held_item(key, new_item_id)
   -- IF we didn't have an item and we have one now
   -- OR we did have an item and it does not match the one we have now
   local should_replace_empty = not self[key] and new_item_id
   local should_replace_existing = self[key] and self[key].itemName ~= new_item_id

   if should_replace_empty or should_replace_existing then
      ISLLog.debug("%s held item changed to '%s'", key, new_item_id)
      if not new_item_id then
         -- Handle changing to `nil`
         self[key] = nil
      else
         -- Handle changing to another item
         local is_success, new_item_config = pcall(root.itemConfig, new_item_id)

         if not is_success then
            ISLLog.error(
               "Failed to load itemConfig for '%s'",
               new_item_id
            )
            return
         end
         self.changed = true
         self[key] = new_item_config.config
      end
   end
end
