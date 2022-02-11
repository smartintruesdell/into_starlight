--[[
  A utility for reasoning about what the player is currently holding.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")

-- Constants ------------------------------------------------------------------
local PATH = "/isl/held_items"
local TAG_CONFIG_PATH = PATH.."/item_tag_mappings.config"

local TagConfig = nil

-- Utility Functions ----------------------------------------------------------

--- Given an item config, makes inferences about that item based on its existing
--- properties and tags and then returns a new set of tags.
---
--- Mod authors are notoriously bad at the homogenous application of item tags.
---
--- derive_tags :: ItemConfig -> string[]
local function derive_tags(item_config)
  assert(item_config ~= nil, "`derive_tags` Received a nil item config")
  assert(type(item_config) == "table", "`derive_tags` Recieved a non-table value")

  TagConfig = TagConfig or root.assetJson(TAG_CONFIG_PATH)

  -- Start from the list of `itemTags` on the item config provided.
  local new_tags = StringSet.new(item_config.itemTags or {})

  -- Get any inferred tags from the TagConfig data
  for _, tag in ipairs(item_config.itemTags or {}) do
    if TagConfig.byTag[tag] ~= nil then
      new_tags:add_many(TagConfig.byTag[tag])
    end
  end

  -- Get any inferred category tags from the TagConfig data
  if
    item_config.category ~= nil and
    TagConfig.byCategory[item_config.category]
  then
    new_tags:add_many(
      TagConfig.byCategory[item_config.category]
    )
  end

  if
    item_config.level ~= nil and
    TagConfig.byLevel[math.floor(item_config.level)]
  then
    new_tags:add_many(
      TagConfig.byLevel[math.floor(item_config.level)]
    )
  end

  return new_tags;
end

-- Class ----------------------------------------------------------------------

ISLHeldItems = createClass("ISLHeldItemDetails")

-- Constructor ----------------------------------------------------------------

function ISLHeldItems:init()
  self._left = nil
  self._right = nil
  self.primary = nil
  self.alt = nil
  self.tags = StringSet.new()
end

-- Methods --------------------------------------------------------------------

function ISLHeldItems:read_from_entity(entity_id)
  -- read item data
  local changed = false
  local new_left_id = world.entityHandItem(entity_id, "primary")
  local new_right_id = world.entityHandItem(entity_id, "alt")

  -- Check for changes
  if new_left_id == nil and self._left ~= nil then
    self._left = nil
    changed = true
  elseif
    (not self._left and new_left_id) or
    (new_left_id and self._left.itemName ~= new_left_id)
  then
    local status, item_data = pcall(root.itemConfig, new_left_id)
    if status then
      self._left = item_data.config
      changed = true
    end
  end

  if new_right_id == nil and self._right ~= nil then
    self._right = nil
    changed = true
  elseif
    (not self._right and new_right_id) or
    (new_right_id and self._right.itemName ~= new_right_id)
  then
    local status, item_data = pcall(root.itemConfig, new_right_id)
    if status then
      self._right = item_data.config
      changed = true
    end
  end

  if changed then
    -- When one or more items changed, determine new primary/alt item
    local left_tags = (self._left and derive_tags(self._left)) or StringSet.new()
    local right_tags = (self._right and derive_tags(self._right)) or StringSet.new()
    local alt_tags = nil

    if right_tags.contains("weapon") and not left_tags.contains("weapon") then
      self.primary = self._right
      self.alt = self._left
      self.tags = right_tags
      alt_tags = left_tags
    else
      self.primary = self._left
      self.alt = self._right
      self.tags = left_tags
      alt_tags = right_tags
    end

    -- Perform some weapon super-categorization
    if self.tags:contains("weapon") then
      if alt_tags:contains("weapon") then
        self.tags:add("dualWield")
      elseif self.primary.twoHanded then
        self.tags:add("twoHanded")
      else
        self.tags:add("oneHanded")
      end
    end
  end

  return self, changed
end
