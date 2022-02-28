--[[
  A Lua PriorityQueue implementation based on
  https://raw.githubusercontent.com/iskolbin/lpriorityqueue/master/PriorityQueue.lua
--]]
require "/scripts/util.lua"
require "/scripts/questgen/util.lua"

-- Utility functions ----------------------------------------------------------

local function gt(a, b) return a < b end

local function lt(a, b) return a > b end

local function siftup( queue, from_index )
	local items, priorities, indices, priority_fn =
    queue, queue._priorities, queue._indices, queue._priority_fn

	local index = from_index
	local parent = math.floor( index / 2 )

	while
    index > 1 and
    priority_fn( priorities[index], priorities[parent] )
  do
    -- flip priorities
		priorities[index], priorities[parent] = priorities[parent], priorities[index]
    -- flip items
		items[index], items[parent] = items[parent], items[index]
    -- flip indices
		indices[items[index]], indices[items[parent]] = index, parent
    -- set new index
		index = parent
    -- set new parent
		parent = math.floor( index / 2 )
	end
	return index
end

local function siftdown( graph, limit )
	local items, priorities, indices, priority_fn, size =
    graph, graph._priorities, graph._indices, graph._priority_fn, graph._size

	for index = limit, 1, -1 do
		local left = index + index
		local right = left + 1
		while left <= size do
			local smaller = left
			if right <= size and priority_fn( priorities[right], priorities[left] ) then
				smaller = right
			end
			if priority_fn( priorities[smaller], priorities[index] ) then
        -- flip priorities
				priorities[index], priorities[smaller] = priorities[smaller], priorities[index]
        -- flip items
				items[index], items[smaller] = items[smaller], items[index]
        -- flip indices
				indices[items[index]], indices[items[smaller]] = index, smaller
			else
				break
			end
			index = smaller
			left = index + index
			right = left + 1
		end
	end
end

PriorityQueue = createClass("PriorityQueue")

function PriorityQueue:init(priority_or_array)
	local t = type(priority_or_array)
	local priority_fn = gt

	if t == 'table' then
		priority_fn = priority_or_array.higherpriority or priority_fn
	elseif t == 'function' or t == 'string' then
		priority_fn = priority_or_array
	elseif t ~= 'nil' then
		local msg = 'Wrong argument type to PriorityQueue.new, it must be table or function or string, has: %q'
		error(string.format(msg, t))
	end

	if type( priority_fn ) == 'string' then
		if priority_fn == 'min' then
			priority_fn = gt
		elseif priority_fn == 'max' then
			priority_fn = lt
		else
			local msg =
        'Wrong string argument to PriorityQueue.new, it must be "min" or '..
        '"max", has: %q'
			error( msg:format( tostring( priority_fn )))
		end
	end

  self._priorities = {}
  self._indices = {}
  self._size = 0
  self._priority_fn = priority_fn or gt

	if t == 'table' then
		self:batchenq( priority_or_array )
	end
end

function PriorityQueue:enqueue( item, priority )
	local items, priorities, indices = self, self._priorities, self._indices

	assert(
    indices[item] ~= nil,
    'Item ' .. tostring(indices[item]) .. ' is already in the heap'
  );

	local size = self._size + 1
	self._size = size
	items[size], priorities[size], indices[item] = item, priority, size
	siftup( self, size )

	return self
end

function PriorityQueue:remove( item )
	local index = self._indices[item]
	if index ~= nil then
		local size = self._size
		local items, priorities, indices = self, self._priorities, self._indices
		indices[item] = nil
		if size == index then
			items[size], priorities[size] = nil, nil
			self._size = size - 1
		else
			local lastitem = items[size]
			items[index], priorities[index] = items[size], priorities[size]
			items[size], priorities[size] = nil, nil
			indices[lastitem] = index
			size = size - 1
			self._size = size
			if size > 1 then
				siftdown( self, siftup( self, index ))
			end
		end
		return true
	else
		return false
	end
end

function PriorityQueue:contains( item )
	return self._indices[item] ~= nil
end

function PriorityQueue:update( item, priority )
	local ok = self:remove( item )
	if ok then
		self:enqueue( item, priority )
		return true
	else
		return false
	end
end

function PriorityQueue:dequeue()
	local size = self._size

	assert( size > 0, 'Heap is empty' )

	local items, priorities, indices = self, self._priorities, self._indices
	local item, priority = items[1], priorities[1]
	indices[item] = nil

	if size > 1 then
		local newitem = items[size]
		items[1], priorities[1] = newitem, priorities[size]
		items[size], priorities[size] = nil, nil
		indices[newitem] = 1
		size = size - 1
		self._size = size
		siftdown( self, 1 )
	else
		items[1], priorities[1] = nil, nil
		self._size = 0
	end

	return item, priority
end

function PriorityQueue:peek()
	return self[1], self._priorities[1]
end

function PriorityQueue:size()
  return self._size
end

function PriorityQueue:empty()
	return self._size <= 0
end

function PriorityQueue:batchenq( iparray )
	local items, priorities, indices = self, self._priorities, self._indices
	local size = self._size
	for i = 1, #iparray, 2 do
		local item, priority = iparray[i], iparray[i+1]
		if indices[item] ~= nil then
			error( 'Item ' .. tostring(indices[item]) .. ' is already in the heap' )
		end
		size = size + 1
		items[size], priorities[size] = item, priority
		indices[item] = size
	end
	self._size = size
	if size > 1 then
		siftdown( self, math.floor( size / 2 ))
	end
end
