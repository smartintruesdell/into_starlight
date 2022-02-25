--[[
  UIPerkNode extends UISkillTreeNode to provide types specific rendering
  instructions for the root Species node of the Skills graph
]]
local PATH = "/isl/constellation/skilltree/nodes"

require "/scripts/util.lua"
require "/scripts/questgen/util.lua"
require "/isl/constants/strings.lua"
require "/isl/lib/log.lua"
require(PATH.."/node.lua")

local Assets = nil

-- Class ----------------------------------------------------------------------

UIPerkNode = defineSubclass(UISkillTreeNode, "UIPerkNode")()

-- Constructor ----------------------------------------------------------------

function UIPerkNode:init(skill, canvas)
  ISLStrings.initialize()
  Assets = Assets or root.assetJson(PATH.."/perk_node_assets.config")
  self.defaultBackground = Assets.background.default

  -- Validations
  assert(skill ~= nil, "Tried to instantiate a UIPerkNode without a Skill")
  assert(
    skill.type == "perk",
    string.format(
      "Tried to render a '%s' skill as a Perk node",
      skill.type
    )
  )

  UISkillTreeNode.init(self, skill, canvas) -- super()

  -- Set the background based on the bonus type
  self.background = skill.background or Assets.background[skill.perkType]
  assert(self.background ~= nil, "Failed to find a background for "..skill.id)

  -- Set the tooltip config
  ISLLog.debug(util.tableToString(skill.strings))
  self.tooltip = root.assetJson(PATH.."/perk_node_tooltip.config")
  ISLLog.debug(skill.strings.name)
  self.tooltip.perkNameLabel.value =
    "^shadow;"..(Strings:getString(skill.strings.name) or skill.id)
  ISLLog.debug(skill.strings.description)
  self.tooltip.perkDetailsLabel.value =
    Strings:getString(skill.strings.description) or "Nondescript"
  self.tooltip.perkTypeIcon.file =
    self.tooltip.perkTypeIcon.file..":"..self.skill.perkType..":saved"
end

function UIPerkNode:get_background_image(_skilltree_state)
  assert(SkillGraph ~= nil, "Tried to draw nodes without a valid SkillGraph")
  local background_image = nil
  if SkillGraph.unlocked_skills:contains(self.skill.id) then
    if SkillGraph.saved_skills:contains(self.skill.id) then
      background_image = self.background..":saved"
    else
      background_image = self.background..":new"
    end
  elseif SkillGraph.available_skills:contains(self.skill.id) then
    background_image = self.background..":available"
  else
    background_image = self.background..":unavailable"
  end
  return background_image
end

function UIPerkNode:createTooltip(position, skilltree_state)
  local is_mouseover = self:area_contains_position(
    skilltree_state.drag_offset,
    position
  )
  if is_mouseover then
    if player.isAdmin() then
      self.tooltip.admin_label.value = "^shadow;"..self.skill.id
      self.tooltip.admin_label.visible = true
    else
      self.tooltip.admin_label.visible = false
    end

    return self.tooltip
  end
end

-- Disabled for now, because I'm thinking perks don't do basic stats ----------

-- local stat_order = {
--   "isl_strength",
--   "isl_defense",
--   "isl_precision",
--   "isl_evasion",
--   "isl_wits",
--   "isl_focus",
--   "isl_vigor",
--   "isl_mobility",
--   "isl_charisma",
--   "isl_crit_chance",
--   "isl_celerity"
-- }
-- function UIPerkNode:get_tooltip_details()
--   ISLStrings.initialize()
--   local details = ""
--   for _, stat_id in ipairs(stat_order) do
--     if self.skill.unlocks.stats[stat_id] then
--       if
--         self.skill.unlocks.stats[stat_id].amount ~= nil and
--         self.skill.unlocks.stats[stat_id].amount > 0
--       then
--         details = details..string.format(
--           Strings:getString("bonus_node_detail_"..stat_id),
--           self.skill.unlocks.stats[stat_id].amount
--         ).."\n"
--       end
--       if
--         self.skill.unlocks.stats[stat_id].multiplier ~= nil and
--         self.skill.unlocks.stats[stat_id].multiplier > 1
--       then
--         details = details..string.format(
--           Strings:getString("bonus_node_detail_"..stat_id),
--           (self.skill.unlocks.stats[stat_id].multiplier - 1).."%"
--                                         ).."\n"
--       end
--     end
--   end
--   return details
-- end
