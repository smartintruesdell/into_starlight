--[[
   Utility functions used by various mod scripts

   Taken whole-cloth from Frackin' Universe's `zb_util` module, then
   cleaned up for readability.
]]

-- Preventing potential overrides
ISLUtil = ISLUtil or {}

-- Clamps the first number to the given range
function ISLUtil.clamp(min, max, value) -- luacheck: ignore 142
   return math.max(min, math.min(value, max))
end

--- Prints the contents of the given table to the SB log
function ISLUtil.printTable(tbl)
   if type(tbl) == "table" then
      local str = "\n{"
      for k, v in pairs(tbl) do
         local lenFix = ""
         for _ = 1, 30 - string.len(tostring(k)) do
            lenFix = lenFix.." "
         end

         str = str.."\n  "..tostring(k)..lenFix.."=          ("..type(v)..") "..tostring(v)
      end

      sb.logInfo("\n%s", str.."\n}")
   else
      sb.logInfo("\n%s", tbl)
   end
end

--- Recursively applies ..PrintTable to `tbl` and its members
function ISLUtil.deepPrintTable(tbl)
   sb.logInfo("%s", ISLUtil._deepPrintTableHelper(tbl, 0))
end

function ISLUtil._deepPrintTableHelper(toPrint, level)
   level = level or 0
   local str = ""

   if type(toPrint) == "table" then
      for k, v in pairs(toPrint) do
         for _ = 0, level do
            str = str.."  "
         end

         local lenFix = ""
         for _ = 1, 30 - string.len(tostring(k)) do
            lenFix = lenFix.." "
         end

         str = str..tostring(k)..lenFix.."=          ("..type(v)..") "..tostring(v)

         if type(v) == "table" then
            str = str..ISLUtil._deepPrintTableHelper(v, level +1).."\n"
         else
            str = str.."\n"
         end
      end

   else
      str = tostring(toPrint)
   end

   return "\n"..str
end

--- Turns a number between 0 and 255 into hex (0 = 00, 255 = FF)
function ISLUtil.RGBToHex(num)
   num = ISLUtil.clamp(math.floor(num + 0.5), 0, 255) -- luacheck: ignore 143

   local hexidecimal = "0123456789ABCDEF"
   local units = num%16+1
   local tens = math.floor(num/16)+1
   return string.sub(hexidecimal, tens, tens)..string.sub(hexidecimal, units, units)
end

--- Turns a number between 0 and 1 into the hex equivalent.
function ISLUtil.ValToHex(num)
   return ISLUtil.RGBToHex(255 * math.clamp(num, 0, 1))
end

--- Turns a hex into a number between 0 and 255
function ISLUtil.HexToRGB(hex)
   hex = string.upper(hex)
   if string.len(hex) == 1 then
      hex = "0"..hex
   elseif string.len(hex) == 0 then
      return 0
   end

   local hexidecimal = "0123456789ABCDEF"
   local tens = string.find(hexidecimal, string.sub(hex,1,1))
   local units = string.find(hexidecimal, string.sub(hex,2,2))
   return (tonumber(tens)-1)*16 + (tonumber(units)-1)
end

--- Returns a modified two-digit hex faded in the requested direction
--- of the received two-digit hex
---
--- `target` expects a hex value the modification should not exceed.
--- If fading in, and increasing "10" hex by 5, but target is "13", it
--- will go up to "13" instead of to "15"
function ISLUtil.FadeHex(hex, fade, amount, target)
   if target then target = ISLUtil.HexToRGB(hex) end
   amount = math.floor(amount+0.5)
   fade = string.lower(fade)

   local rgbValue = ISLUtil.HexToRGB(hex)

   if fade == "out" then
      rgbValue = math.max(target or 0, rgbValue - amount)
   elseif fade == "in" then
      rgbValue = math.min(target or 255, rgbValue + amount)
   else
      sb.logError("[ISL] ERROR - 'ISLUtil.FadeHex' 2nd arguement not 'in' or 'out'")
      return "00"
   end

   return ISLUtil.RGBToHex(rgbValue)
end

--- Merges tables.
---
--- Unlike vanilla 'util.MergeTable', merges arrays (aka 'ipairs' table) instead
--- of overriding them
function ISLUtil.MergeTable(t1, t2)
   if ISLUtil.IsArray(t2) then
      for _, v in ipairs(t2) do
         table.insert(t1, v)
      end
   elseif ISLUtil.IsArray(t1) then
      local length = #t2
      for _, v in ipairs(t2) do
         table.insert(t1, v)
      end

      for k, v in pairs(t2) do
         if type(k) ~= "number" or k > length then
            if type(v) == "table" and type(t1[k]) == "table" then
               ISLUtil.MergeTable(t1[k] or {}, v)
            else
               t1[k] = v
            end
         end
      end
   else
      for k, v in pairs(t2) do
         if type(v) == "table" and type(t1[k]) == "table" then
            ISLUtil.MergeTable(t1[k] or {}, v)
         else
            t1[k] = v
         end
      end
   end
   return t1
end

--  Returns true if the table is an array ('ipairs' table)
function ISLUtil.IsArray(tbl)
   if type(tbl) == "table" then
      local length = #tbl
      for i, _ in pairs(tbl) do
         if type(i) ~= "number" or i > length then
            return false
         end
      end
      return true
   end
   return false
end


-- Returns just the keys of a table
function ISLUtil.keys(tbl)
   local res = {}
   for key, _ in pairs(tbl) do
      table.insert(res, key)
   end
   return res
end

-- Returns just the values of a table
function ISLUtil.values(tbl)
   local res = {}
   for _, val in pairs(tbl) do
      table.insert(res, val)
   end
   return res
end
