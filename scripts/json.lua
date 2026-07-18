local json = {}

local function escape_string(str)
   str = str:gsub("\\", "\\\\")
   str = str:gsub('"', '\\"')
   str = str:gsub("\n", "\\n")
   str = str:gsub("\r", "\\r")
   str = str:gsub("\t", "\\t")

   return '"' .. str .. '"'
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

   return count == max
end

function json.encode(value)
   local t = type(value)

   if t == "string" then
      return escape_string(value)

   elseif t == "number" then
      return tostring(value)

   elseif t == "boolean" then
      return tostring(value)

   elseif t == "table" then
      if is_array(value) then
	 local items = {}

	 for _, item in ipairs(value) do
	    table.insert(items, json.encode(item))
	 end

	 return "[" .. table.concat(items, ",") .. "]"
      else
	 local items = {}

	 for key, item in pairs(value) do
	    table.insert(
	       items,
	       escape_string(tostring(key)) .. ":" .. json.encode(item)
	    )
	 end

	 return "{" .. table.concat(items, ",") .. "}"
      end

   else
      error("Cannot encode type: " .. t)
   end
end

return json
