--[[
  A utility for reasoning about what the player is currently holding.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/string_set.lua")

-- Constants ------------------------------------------------------------------
local PATH = "/isl/held_items"
local TAG_CONFIG_PATH = PATH.."/item_tag_mappings.config"

-- Class ----------------------------------------------------------------------

ISLHeldItemsManager = createClass("ISLHeldItemDetails")

-- Constructor ----------------------------------------------------------------

function ISLHeldItemsManager:init(entity_id)
  self.entity_id = entity_id

  self.primary = nil
  self.alt = nil
  self.tags = {
    primary = StringSet.new(),
    alt = StringSet.new()
  }

  self:update()
end

-- Methods --------------------------------------------------------------------
function ISLHeldItemsManager:update(--[[dt: number]])
  local changed = false
  changed = self:update_held_item(
    'primary',
    world.entityHandItem(self.entity_id, "primary")
  )
  changed = self:update_held_item(
    'alt',
    world.entityHandItem(self.entity_id, "alt")
  ) or changed

  return changed
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
      self.tags[key] = {}
    else
      -- Handle changing to another item
      local is_success, new_item_data = pcall(root.itemConfig, new_item_id)

      if not is_success then
        ISLLog.error(
          "Failed to load itemConfig for '%s'",
          new_item_id
        )
        return
      end
      self.changed = true
      self[key] = new_item_data.config
      self.tags[key] = ISLHeldItemsManager.derive_tags(new_item_data.config)
    end
  end
end

--- Given an item config, makes inferences about that item based on its existing
--- properties and tags and then returns a new set of tags.
---
--- Mod authors are notoriously bad at the homogenous application of item tags.
---
--- derive_tags :: ItemConfig -> string[]
function ISLHeldItemsManager.derive_tags(item_config)
  assert(item_config ~= nil, "`derive_tags` Received a nil item config")

  ISLHeldItemsManager.TagConfig = ISLHeldItemsManager.TagConfig or root.assetJson(TAG_CONFIG_PATH)

  -- Start from the list of `itemTags` on the item config provided.
  local new_tags = StringSet.new(item_config.itemTags or {})

  -- Get any inferred tags from the TagConfig data
  for _, tag in ipairs(item_config.itemTags or {}) do
    if ISLHeldItemsManager.TagConfig.byTag[tag] then
      new_tags.add_many(ISLHeldItemsManager.TagConfig.byTag[tag])
    end
  end

  -- Get any inferred category tags from the TagConfig data
  if
    item_config.category ~= nil and
    ISLHeldItemsManager.TagConfig.byCategory[item_config.category]
  then
    new_tags.add_many(
      ISLHeldItemsManager.TagConfig.byCategory[item_config.category]
    )
  end

  if
    item_config.level ~= nil and
    ISLHeldItemsManager.TagConfig.byLevel[math.floor(item_config.level)]
  then
    new_tags.add_many(
      ISLHeldItemsManager.TagConfig.byLevel[math.floor(item_config.level)]
    )
  end

  return new_tags;
end
