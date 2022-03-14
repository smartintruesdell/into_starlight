--[[
  Logic related to earning Skill Points when collecting Skill Motes
]]
-- Constants ------------------------------------------------------------------
local PATH = "/isl/skill_points"
local ConfigFilePath = PATH.."/skill_points.config"

ISLSkillPoints = ISLSkillPoints or {}

-- Utility functions ----------------------------------------------------------

local function default_to_player_id(entity_id)
  entity_id = entity_id or (player and player.id())
  assert(entity_id ~= nil, "Tried to get skill points for a nil player")

  return entity_id
end

--- Given a list of numbers and a target number, returns the INDEX of the element
--- in the list where that element is less than the input but the next element
--- (i+1) is greater than the input.
---@param range_list table An array of numbers
---@param input number A search number
---@param _min_index number Used to avoid slicing during recursion
---@param _max_index number Used to avoid slicing during recursion
local function binary_search_range_match(range_list, input, _min_index, _max_index)
  assert(#range_list, "binary_search_range_match called with an empty set")
  assert(input ~= nil, "binary_search_range_match called without valid input")
  _min_index = _min_index or 1
  _max_index = _max_index or #range_list

  -- Find the midpoint, round down
  local midpoint = math.floor((_max_index - _min_index) / 2) + _min_index

  if
    -- If the element at `midpoint` is the start of a range including `input`,
    -- return it.
    range_list[midpoint] <= input and
    (range_list[midpoint+1] == nil or range_list[midpoint+1] > input)
  then
    return midpoint
  end

  -- We did not have a hit, so we'll recurse.
  if midpoint > _min_index then
    local left_result = binary_search_range_match(range_list, input, _min_index, midpoint-1)
    if left_result then return left_result end
  end
  if midpoint < _max_index then
    return binary_search_range_match(range_list, input, midpoint+1, _max_index)
  end

  return nil
end

function ISLSkillPoints.get_available_skill_points(entity_id)
  entity_id = default_to_player_id(entity_id)

  return world.entityCurrency(entity_id, "isl_skill_point")
end

function ISLSkillPoints.get_earned_skill_points_for_motes(motes)
  assert(motes ~= nil, "get_earned_skill_points_for_motes called with nil argument")
  ISLSkillPoints.Config =
    ISLSkillPoints.Config or root.assetJson(ConfigFilePath)

  return binary_search_range_match(
    ISLSkillPoints.Config.leveling,
    motes
  ) or 0
end

function ISLSkillPoints.get_earned_skill_points(entity_id)
  entity_id = default_to_player_id(entity_id)

  -- Collected motes
  local collected_motes = ISLSkillPoints.get_skill_motes(entity_id)

  if collected_motes ~= nil then
    return ISLSkillPoints.get_earned_skill_points_for_motes(collected_motes)
  end
  return 0
end

function ISLSkillPoints.get_skill_motes_for_skill_point(skill_point)
  ISLSkillPoints.Config =
    ISLSkillPoints.Config or root.assetJson(ConfigFilePath)

  if skill_point == 0 then
    return 0
  elseif
    skill_point > 0 and
    skill_point <= #ISLSkillPoints.Config.leveling
  then
    return ISLSkillPoints.Config.leveling[skill_point]
  end
  ISLLog.debug(
    "Could not get motes for skill point %d, there are %d known values",
    skill_point,
    #ISLSkillPoints.Config.leveling
  )
  return nil
end

function ISLSkillPoints.get_skill_motes(entity_id)
  entity_id = default_to_player_id(entity_id)

  return world.entityCurrency(entity_id, "isl_skill_mote")
end

function ISLSkillPoints.get_effective_level(entity_id)
  entity_id = default_to_player_id(entity_id)

  return math.floor(ISLSkillPoints.get_earned_skill_points(entity_id)/10) + 1
end
