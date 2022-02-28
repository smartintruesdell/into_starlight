--[[ Utility for spawning Skill motes ]]
require("/isl/lib/util.lua")

function spawn_skill_motes(entity_pos, player_level, monster_level)
  local relative_pool_level = 2 + ISLUtil.clamp(
    -2,
    2,
    monster_level - player_level
  )

  world.spawnTreasure(
    entity_pos,
    "isl_skillmotepool",
    relative_pool_level
  )
end
