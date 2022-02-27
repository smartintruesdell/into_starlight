--[[
  Perks display subcomponent for the character sheet
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/constants/strings.lua")
require("/isl/lib/log.lua")
require("/isl/lib/string_set.lua")
require("/isl/lib/uicomponent.lua")
require("/isl/skillgraph/skillgraph.lua")

local GRAPH_PERK_ICON_PATH =
  "/isl/constellation/skilltree/nodes/assets/graph_bonus.png"

-- Utility functions ----------------------------------------------------------

local function sort_skill_ids(skill_1_id, skill_2_id)
  return skill_1_id < skill_2_id
end

-- Class ----------------------------------------------------------------------

UIConstellationPerks = defineSubclass(UIComponent, "UIConstellationPerks")()

-- Constructor ----------------------------------------------------------------

function UIConstellationPerks:init(list_id)
  if not Strings then ISLStrings.initialize() end

  self.list_id = list_id
  self.last_unlocked_perks = StringSet.new()
end

-- Methods --------------------------------------------------------------------

function UIConstellationPerks:update(_dt)
  -- If the list of perks in the skill graph changed,
  -- then we'll want to update our list of perks here.
  if
    not self.last_unlocked_perks:equals(SkillGraph.unlocked_perks)
  then
    -- Save it for next time
    self.last_unlocked_perks = SkillGraph.unlocked_perks:clone()

    -- Clear the list
    widget.clearListItems(self.list_id)

    if SkillGraph.unlocked_perks:size() > 0 then
      -- Sort the list of perks by id so that we can keep them
      -- in consistent order between updates
      local perk_ids = SkillGraph.unlocked_perks:to_Vec()
      table.sort(perk_ids,sort_skill_ids)

      -- Iterate over the perks adding them to the list.
      for _, perk_id in ipairs(perk_ids) do
        ISLLog.debug("Adding perk to the list: %s", perk_id)
        local new_item = string.format(
          "%s.%s",
          self.list_id,
          widget.addListItem(self.list_id)
        )
        ISLLog.debug("- new item: %s", new_item)
        widget.setImage(
          new_item..".perkTypeIcon",
          GRAPH_PERK_ICON_PATH..":"..SkillGraph.skills[perk_id].perkType..":saved"
        )
        widget.setText(
          new_item..".perkNameLabel",
          Strings:getString(SkillGraph.skills[perk_id].strings.name)
        )
        widget.setText(
          new_item..".perkDetailsLabel",
          Strings:getString(SkillGraph.skills[perk_id].strings.description)
        )
      end
    end
  end
end
