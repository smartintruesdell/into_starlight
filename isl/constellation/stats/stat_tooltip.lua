require("/isl/constants/colors.lua")

local PATH = "/isl/constellation/stats/"

local ButtonDefinitions = {
  strengthButton = { stat = "isl_strength", color = "melee" },
  precisionButton = { stat = "isl_precision", color = "ranged" },
  witsButton = { stat = "isl_wits", color = "magical" },
  defenseButton = { stat = "isl_defense", color = "melee" },
  evasionButton = { stat = "isl_evasion", color = "ranged" },
  focusButton = { stat = "isl_focus", color = "magical"},
  vigorButton = { stat = "isl_vigor", color = "vital"},
  savageryButton = { stat = "isl_savagery", color = "vital"},
  mobilityButton = { stat = "isl_mobility", color = "speedy"},
  celerityButton = { stat = "isl_celerity", color = "speedy"},
  charismaButton = { stat = "isl_charisma", color = "vital"}
}

function create_stat_tooltip(child_id, title_string_id, desc_string_id)
  if ButtonDefinitions[child_id] ~= nil then
    local tooltip = root.assetJson(PATH.."stat_tooltip.config")

    tooltip.title.value = Strings:getString(title_string_id)
    tooltip.description.value = Strings:getString(desc_string_id)

    local color =
      "^"..Colors.get_color(ButtonDefinitions[child_id].color)..";"
    local reset = "^reset;"
    local details = SkillGraph:get_stat_details(
      ButtonDefinitions[child_id].stat
    )

    tooltip.details.value = string.format(
      Strings:getString("stats_details"),
      color..details.from_species..reset,
      player.species(),
      color..details.from_skills..reset,
      color..details.from_perks..reset
    )

    return tooltip
  end
end
