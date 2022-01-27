--[[
   A logging abstraction for IntoStarlight scripts
]]

-- Constants ------------------------------------------------------------------

--- LOG_LEVEL determiens how verbose we want to be:
---
--- 0: Debug,   log everything
--- 1: Warn,    log non-breaking warnings
--- 2: Info,    log useful process and descriptive information
--- 3: Error,   log errors
local LOG_LEVELS = {}
LOG_LEVELS.DEBUG = 0;
LOG_LEVELS.WARN = 1;
LOG_LEVELS.INFO = 2;
LOG_LEVELS.ERROR = 3;

local LOG_LEVEL = LOG_LEVELS.DEBUG

-- Exports --------------------------------------------------------------------
ISLLog = ISLLog or {}

local function print_lg(pre, msg, ...)
   sb.logInfo(string.format("ISL:%s: "..msg, pre, ...))
end

function ISLLog.debug(msg, ...)
   if LOG_LEVEL == LOG_LEVELS.DEBUG then print_lg("DEBUG", msg, ...) end

   return message
end
function ISLLog.warn(msg, ...)
   if LOG_LEVEL <= LOG_LEVELS.WARN then print_lg("WARN", msg, ...) end

   return message
end
function ISLLog.info(msg, ...)
   if LOG_LEVEL <= LOG_LEVELS.INFO then print_lg("INFO", msg, ...) end

   return message
end
function ISLLog.error(msg, ...)
   if LOG_LEVEL <= LOG_LEVELS.ERROR then print_lg("ERROR", msg, ...) end

   return message
end
