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
  self.tooltip = root.assetJson(PATH.."/perk_node_tooltip.config")
  self.tooltip.perkNameLabel.value =
    "^shadow;"..(Strings:getString(skill.strings.name) or skill.id)
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
    if not SkillGraph.unlocked_skills:contains(self.skill.id) then
      SkillGraph:highlight_path_to_skill(self.skill.id)
      skilltree_state.redraw()
    end

    if player.isAdmin() then
      self.tooltip.admin_label.value = "^shadow;"..self.skill.id
      self.tooltip.admin_label.visible = true
    else
      self.tooltip.admin_label.visible = false
    end

    return self.tooltip
  end
end
