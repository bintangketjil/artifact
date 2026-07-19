local script_path = debug.getinfo(1).source:match("@?(.*/)")
package.path = package.path .. ";" .. script_path .. "?.lua"

local json = require "json"

local metadata = {}

function Meta(meta)
   metadata = {}

   for key, value in pairs(meta) do
     metadata[key] = normalize(value)
   end
   -- print(json.encode(entry))
   return meta
end

function Pandoc(doc)
   io.write(json.encode(metadata))
   doc.blocks= {}
   return doc
end

-- TODO:
-- move dump() to util.lua
function dump(value, indent)
   indent = indent or 0
   local spacing = string.rep(" ", indent)

   if type(value) ~= "table" then
      print(spacing .. tostring(value))
      return
   end

   print(spacing .. "{")

   for key, item in pairs(value) do
      io.write(spacing .. " " .. tostring(key) .. "=")

      if type(item) == "table" then
	 print()
	 dump(item, indent + 1)
      else
	 print(tostring(item))
      end
   end

   print(spacing .. "}")
end

function normalize(value)
   local t = pandoc.utils.type(value)

   if t == "Blocks" then
      return nil
   end

   if t == "Inlines" then
      local str = pandoc.utils.stringify(value)

      if tonumber(str) then
	 return tonumber(str)
      end

      return str

   elseif t == "List" then
      local result = {}

      for _, item in ipairs(value) do
	 table.insert(result, normalize(item))
      end

      return result
      
   elseif t == "boolean" then
      return value

   elseif t == "number" then
      return value

   elseif t == "table" then
      local result = {}

      for key, item in pairs(value) do
	 result[key] = normalize(item)
      end
      
      return result
      
   else
      print("\nERROR:")
      print("type:", t)
      print(value)
      error("Unsupported metadata type: " .. t)
   end
end
