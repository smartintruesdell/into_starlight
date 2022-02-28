--[[
  Utility functions for deriving the shortest-path between two nodes on
  the skill graph.

  This is used to validate selections "if I toggle this node, do my children
  have a path to the origin" and to enable quick-selection to a desired node
]]
require "/isl/lib/priority_queue.lua"
require "/isl/lib/string_set.lua"

-- Utility functions ----------------------------------------------------------

function table_clone(tbl)
    local t = {}

    for _, v in pairs(tbl) do
        table.insert(t, v)
    end

    return t
end

function find_shortest_path(graph, start_id, goal_id, include_locked_skills, exclude_nodes)
  assert(graph.skills[start_id] ~= nil, "Could not find the starting node")
  assert(graph.skills[goal_id] ~= nil, "Could not find the goal node")
  exclude_nodes = exclude_nodes or StringSet.new()

  local queue = PriorityQueue.new('min'):enqueue({ start_id }, 0)
  local visited = StringSet.new({ start_id })
  local best_path, best_cost = nil, 999

  while queue:size() > 0 do
    local path, cost = queue:dequeue()
    local node_id = path[#path]

    if node_id == goal_id then
      -- If this path goes to the end node,
      if cost < best_cost then
        -- save it to the best path if it's better
        best_path = path
        best_cost = cost
      end
      -- and skip further processing on this route
      goto continue
    end

    for _, exit_id in ipairs(graph.skills[node_id].children:to_Vec()) do
      if not visited:contains(exit_id) and not exclude_nodes:contains(exit_id) then
        visited:add(exit_id)

        assert(graph.skills[exit_id] ~= nil, "Skill was not available: "..exit_id)

        local new_path = table_clone(path)
        assert(new_path ~= nil, "nil Path was cloned")
        table.insert(new_path, exit_id)

        if graph.unlocked_skills:contains(exit_id) then
          queue:enqueue( new_path, cost )
        elseif include_locked_skills then
          queue:enqueue( new_path, cost + 1 )
        end
      end
    end
    ::continue::
  end

  return best_path, best_cost
end
