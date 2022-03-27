--[[ A plugin for objects/outpost/* shops to make the vendors response to Charisma]]
require "/scripts/util.lua"

local PATH = "/isl/plugins/objects/outpost"
local CONFIG_PATH = PATH.."/outpost_shop_isl_charisma_chattiness.config"

local super_init = init or function() end
function init()
  super_init()
--  ISLStrings.initialize()

  local default_chat_config = root.assetJson(CONFIG_PATH)
  self.chat_options = config.getParameter(
    "chatOptions",
    default_chat_config.chatOptions
  )
  self.charisma_chat_options = config.getParameter(
    "charismaChatOptions",
    default_chat_config.charismaChatOptions
  )
  self.chat_cooldown = config.getParameter(
    "chatCooldown",
    default_chat_config.chatCooldown
  )
  self.chat_radius = config.getParameter(
    "chatRadius",
    default_chat_config.chatRadius
  )
  self.chat_timer = 0
end

local super_update = update or function(_) end
function update(dt)
  super_update(dt)

  self.chat_timer = math.max(0, self.chat_timer - dt)
  if self.chat_timer == 0 then
    local players_in_range = world.entityQuery(
      object.position(),
      self.chat_radius,
      {
        includedTypes = {"player"},
        boundMode = "CollisionArea"
      }
    )

    if #players_in_range > 0 then
      -- First, check for Charisma responses
      if #self.charisma_chat_options > 0 then
        -- TODO: Maybe sort the players by charisma?
        for _, player_id in ipairs(players_in_range) do
          local charisma = status.stat("isl_charisma")

          local valid_charisma_chat_options =
            util.filter(
              self.charisma_chat_options,
              function (option)
                return (
                  (option.min or 0) <= charisma and
                  (option.max or 999) > charisma
                )
              end
            )

          if #valid_charisma_chat_options > 0 then
            local tags = get_charisma_chat_tags(player_id)
            local index = math.random(1, #valid_charisma_chat_options)
            object.say(
              sb.replaceTags(
                valid_charisma_chat_options[index].message,
                tags
              )
            )
            self.chat_timer = self.chat_cooldown
            goto done
          end
        end
      end
      -- Otherwise, check for non-charisma responses
      if #self.chat_options > 0 then
        object.say(self.chatOptions[math.random(1, #self.chatOptions)])
        self.chat_timer = self.chat_cooldown
        goto done
      end
    end
  end
  ::done::
end

function get_charisma_chat_tags(player_id)
  return {
    name = world.entityName(player_id)
  }
end
