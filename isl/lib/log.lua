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
LOG_LEVELS = {}
LOG_LEVELS.DEBUG = 0;
LOG_LEVELS.WARN = 1;
LOG_LEVELS.INFO = 2;
LOG_LEVELS.ERROR = 3;

LOG_LEVEL = LOG_LEVELS.DEBUG

-- Exports --------------------------------------------------------------------
ISLLog = ISLLog or {}

function ISLLog.debug(msg, ...)
   if LOG_LEVEL == LOG_LEVELS.DEBUG then
      sb.logInfo(string.format("ISL:: (DEBUG) "..msg, ...))
   end

   return msg
end
function ISLLog.warn(msg, ...)
   if LOG_LEVEL <= LOG_LEVELS.WARN then
      sb.logWarn(string.format("ISL:: "..msg, ...))
   end

   return msg
end
function ISLLog.info(msg, ...)
   if LOG_LEVEL <= LOG_LEVELS.INFO then
      sb.logInfo(string.format("ISL:: "..msg, ...))
   end

   return msg
end
function ISLLog.error(msg, ...)
   if LOG_LEVEL <= LOG_LEVELS.ERROR then
      sb.logError(string.format("ISL:: "..msg, ...))
   end

   return msg
end
