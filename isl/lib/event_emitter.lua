--[[
   General purpose event emitter for Lua
]]
EventEmitter = createClass("EventEmitter")

function EventEmitter:init()
   self.handlers = {}
end

function EventEmitter:addEventListener(event_name, handler_name, handler)
   self.handlers[event_name] = self.handlers[event_name] or {}
   self.handlers[event_name][handler_name] = handler

   return self
end

function EventEmitter:removeEventListener(event_name, handler_name)
   self.handlers[event_name] = self.handlers[event_name] or {}
   self.handlers[event_name][handler_name] = nil

   return self
end

function EventEmitter:emit(event_name, ...)
   for _, handler in pairs(self.handlers[event_name] or {}) do
      if handler then
         handler(...)
      end
   end

   return self
end
