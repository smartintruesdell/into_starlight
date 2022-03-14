--[[
  An effect controller attached to the player which monitors for updates to
  the player's Skill Motes currency and rewards Skill Points when the player passes
  the appropriate thresholds.
]]
require("/scripts/util.lua")
require("/scripts/questgen/util.lua")
require("/isl/lib/log.lua")
require("/isl/player/skill_points/skill_points.lua")

-- Class ----------------------------------------------------------------------

ISLSkillPointController = createClass("ISLSkillPointController")

-- Constructor ---------------------------------------------------------------

function ISLSkillPointController:init(entity_id)
  assert(entity_id ~= nil, "Initialize ISLSkillPointController with an entity_id")
  self.entity_id = entity_id
  self.state = {}
  self.state.last_skill_motes = nil
end

-- Methods --------------------------------------------------------------------

function ISLSkillPointController:update(dt)
  -- Get the current isl_skill_mote count
  local next_motes = ISLSkillPoints.get_skill_motes(self.entity_id)
  -- If we didn't have a last motes to compare to, we'll early out.
  if self.state.last_skill_motes == nil then
    self.state.last_skill_motes = next_motes
    return
  end

  -- If it is unchanged, early out
  if next_motes == self.state.last_skill_motes then return end

  -- Otherwise, we'll check to see if the earned skill points has changed
  local last_earned_points =
    ISLSkillPoints.get_earned_skill_points_for_motes(self.state.last_skill_motes or 0)
  local next_earned_points =
    ISLSkillPoints.get_earned_skill_points_for_motes(next_motes)

  -- If they're the same, early out
  if last_earned_points == next_earned_points then
    return
  end

  -- Otherwise award the player another skill point
  self.state.last_skill_motes = next_motes

  status.addEphemeralEffect("isl_skill_point_up_particle") -- "Skill Up!"

  world.spawnItem(
    "isl_skill_point",
    entity.position(),
    next_earned_points - last_earned_points
  )
end
