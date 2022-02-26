--[[
  UIBonusNode extends UIComponent to provide types specific rendering
  instructions for Bonus nodes of the Skills graph
]]
local PATH = "/isl/constellation/skilltree/nodes"

require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require(PATH.."/node.lua")

local Assets = nil

-- Class ----------------------------------------------------------------------

UIBonusNode = defineSubclass(UISkillTreeNode, "UIBonusNode")()

-- Constructor ----------------------------------------------------------------

function UIBonusNode:init(skill, canvas)
  Assets = Assets or root.assetJson(PATH.."/bonus_node_assets.config")
  self.defaultBackground = Assets.background.default

  -- Validations
  assert(skill ~= nil, "Tried to instantiate a UIBonusNode without a Skill")
  assert(
    skill.type == "bonus",
    string.format(
      "Tried to render a '%s' skill as a Bonus node",
      skill.type
    )
  )

  UISkillTreeNode.init(self, skill, canvas) -- super

  -- Set the background based on the bonus type
  self.background = skill.background or Assets.background[skill.background_type]
  assert(self.background ~= nil, "Failed to find a background for "..skill.id)

  self.tooltip = root.assetJson(PATH.."/bonus_node_tooltip.config")
end

-- Overrides -----------------------------------------------------------------

function UIBonusNode:get_background_image(_skilltree_state)
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

-- Methods --------------------------------------------------------------------

function UIBonusNode:createTooltip(position, skilltree_state)
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

    self.tooltip.details.value = self:get_tooltip_details()

    return self.tooltip
  end
end

local stat_order = {
  "isl_strength",
  "isl_defense",
  "isl_precision",
  "isl_evasion",
  "isl_wits",
  "isl_focus",
  "isl_vigor",
  "isl_mobility",
  "isl_charisma",
  "isl_celerity",
  "isl_savagery"
}
function UIBonusNode:get_tooltip_details()
  ISLStrings.initialize()
  local details = ""
  for _, stat_id in ipairs(stat_order) do
    if self.skill.unlocks.stats[stat_id] then
      if
        self.skill.unlocks.stats[stat_id].amount ~= nil and
        self.skill.unlocks.stats[stat_id].amount > 0
      then
        details = details..string.format(
          Strings:getString("bonus_node_detail_"..stat_id),
          self.skill.unlocks.stats[stat_id].amount
        ).."\n"
      end
      if
        self.skill.unlocks.stats[stat_id].multiplier ~= nil and
        self.skill.unlocks.stats[stat_id].multiplier > 1
      then
        details = details..string.format(
          Strings:getString("bonus_node_detail_"..stat_id),
          (self.skill.unlocks.stats[stat_id].multiplier - 1).."%"
        ).."\n"
      end
    end
  end
  return details
end
