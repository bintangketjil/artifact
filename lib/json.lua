local json = {}

local function escape_string(str)
   str = str:gsub("\\", "\\\\")
   str = str:gsub('"', '\\"')
   str = str:gsub("\n", "\\n")
   str = str:gsub("\r", "\\r")
   str = str:gsub("\t", "\\t")

   return '"' .. str .. '"'
end

local function indent(level)
   return string.rep("  ", level)
end

local function is_array(tbl)
   local count = 0
   local max = 0

   for key, _ in pairs(tbl) do
      if type(key) ~= "number" then
	 return false
      end

      if key > max then
	 max = key
      end
      
      count = count + 1
   end

   if count == 0 then
      return false
   end

   return count == max
end

local function sorted_keys(tbl)
   local keys ={}

   for key in pairs(tbl) do
      table.insert(keys, key)
   end

   table.sort(keys)

   return keys
end

local function encode(value, pretty, level)
   level = level or 0

   local t = type(value)

   if value == nil then
      return "null"

   elseif t == "string" then
      if pretty and #value > 120 then
	 return escape_string("<" .. #value .. " bytes>")
      end

      return escape_string(value)

   elseif t == "number" or t == "boolean" then
      return tostring(value)

   elseif t == "table" then
      if is_array(value) then
	 local items = {}

	 for _, item in ipairs(value) do
	    table.insert(items, encode(item, pretty, level + 1))
	 end

	 if not pretty then
	    return "[" .. table.concat(items, ",") .. "]"
	 end

	 if #items == 0 then
	    return "[]"
	 end

	 return "[\n"
	    .. indent(level + 1)
	    .. table.concat(items, ",\n" .. indent(level + 1))
	    .. "\n"
	    .. indent(level)
	    .. "]"
      else
	 local items = {}

	 for _, key in ipairs(sorted_keys(value)) do
	    local item = value[key]

	    local separator = pretty and ": " or ":"

	    table.insert(
	       items,
	       escape_string(tostring(key))
	       .. separator
	       .. encode(item, pretty, level + 1)
	    )
	 end
	 
	 if not pretty then
	    return "{" .. table.concat(items, ",") .. "}"
	 end
	 
	 if #items == 0 then
	    return "{}"
	 end

	 return "{\n"
	    .. indent(level + 1)
	    .. table.concat(items, ",\n" .. indent(level + 1))
	    .. "\n"
	    .. indent(level)
	    .. "}"
      end
   else
      error("Cannot encode type: " .. t)
   end
end

-- TODO:
-- implement decode
local function decode(value)

end

function json.encode(value)
   return encode(value, false, 0)
end

function json.pretty(value)
   return encode(value, true, 0)
end

return json
