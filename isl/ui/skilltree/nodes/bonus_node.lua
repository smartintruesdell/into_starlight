--[[
   UIBonusNode extends UIComponent to provide types specific rendering
   instructions for Bonus nodes of the Skills graph
]]
local PATH = "/isl/ui/skilltree/nodes"

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
   self.defaultMask = Assets.mask.default
   self.defaultIcon = Assets.icon.default

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

   -- Set the icon based on the primary stat
   local primary_stat = self:get_primary_stat()
   self.icon = skill.icon or Assets.icon[primary_stat] or Assets.icon.default
end

-- Overrides -----------------------------------------------------------------

function UIBonusNode:get_background_image(skilltree_state)
   skilltree_state = skilltree_state or {
      unlocked_skills = {},
      available_skills = {}
   }
   local background_image = nil
   if skilltree_state.unlocked_skills[self.skill.id] ~= nil then
      background_image = self.background..":unlocked"
   elseif skilltree_state.available_skills[self.skill.id] ~= nil then
      background_image = self.background..":available"
   else
      background_image = self.background..":unavailable"
   end
   return background_image
end

-- Methods --------------------------------------------------------------------

function UIBonusNode:get_primary_stat()
   local primary_stat = nil

   for stat_id, value in pairs(self.skill.unlocks.stats) do
      if not primary_stat or value > self.skill.unlocks.stats[primary_stat] then
         primary_stat = stat_id
      end
   end

   return primary_stat
end
