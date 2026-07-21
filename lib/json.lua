local json = {}
json.null = setmetatable({}, {
      __tostring = function()
	 return "null"
      end
})


-- helper

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

-- encode

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

-- parser

local Parser = {}
Parser.__index = Parser

function Parser.new(text)
   return setmetatable({
	 text = text,
	 pos = 1,
   }, Parser)
end

function Parser:peek()
   return self.text:sub(self.pos, self.pos)
end

function Parser:advance()
   local ch = self:peek()
   self.pos = self.pos + 1
   return ch
end

function Parser:error(message)
   error(string.format("%s at position %d", message, self.pos))
end

function Parser:expect(expected)
   local ch = self:advance()

   if ch == "" then
      self:error(string.format(
		    "expected '%s', reached end of input",
		    expected
      ))
   end

   if ch ~= expected then
      self:error(string.format(
		    "expected '%s', got '%s'",
		    expected,
		    ch
      ))
   end
end

function Parser:skip_whitespace()
   while true do
      local ch = self:peek()

      if ch == " "
	 or ch == "\n"
	 or ch == "\r"
	 or ch == "\t"
      then
	 self:advance()
      else
	 break
      end
   end
end

function Parser:parse_value()
   self:skip_whitespace()

   local ch = self:peek()

   if ch == '"' then
      return self:parse_string()
   end

   if ch == "-" or (ch >= "0" and ch <= "9") then
      return self:parse_number()
   end

   if ch == "t" then
      return self:parse_literal("true", true)
   end

   if ch == "f" then
      return self:parse_literal("false", false)
   end

   if ch == "n" then
      return self:parse_literal("null", json.null)
   end

   if ch == "[" then
      return self:parse_array()
   end

   if ch == "{" then
      return self:parse_object()
   end
   
   self:error(string.format(
		 "unexpected character '%s'",
		 ch
   ))
end

function Parser:parse_array()
   self:expect("[")

   local array = {}

   self:skip_whitespace()

   if self:peek() == "]" then
      self:advance()
      return array
   end

   while true do
      table.insert(array, self:parse_value())

      self:skip_whitespace()

      local ch = self:peek()

      if ch == "," then
	 self:advance()
	 self:skip_whitespace()

      elseif ch == "]" then
	 self:advance()
	 return array

      else
	 self:error("expected ',' or ']'")
      end
   end
end

function Parser:parse_object()
   self:expect("{")

   local object = {}

   self:skip_whitespace()

   if self:peek() == "}" then
      self:advance()
      
      return object
   end

   while true do
      local key = self:parse_string()

      self:skip_whitespace()
      self:expect(":")
      self:skip_whitespace()

      object[key] = self:parse_value()

      self:skip_whitespace()

      local ch = self:peek()

      if ch == "," then
	 self:advance()
	 self:skip_whitespace()

      elseif ch == "}" then
	 self:advance()
	 return object

      else
	 self:error("expected ',' or '}'")
      end
   end
end

local escapes = {
   ['"'] = '"',
   ['\\'] = '\\',
   ['/'] = '/',
   ['b'] = '\b',
   ['f'] = '\f',
   ['n'] = '\n',
   ['r'] = '\r',
   ['t'] = '\t',
}

function Parser:parse_string()
   self:expect('"')

   local parts = {}

   while true do
      local ch = self:advance()

      if ch == "" then
	 self:error("unterminated string")
      end

      if ch == '"' then
	 return table.concat(parts)
      end

      if ch == '\\' then
	 local esc = self:advance()
	 local value = escapes[esc]

	 if not value then
	    self:error("invalid escape sequence")
	 end

	 table.insert(parts, value)

      else
	 table.insert(parts, ch)
      end
   end
end

function Parser:is_digit(ch)
   return ch >= "0" and ch <= "9"
end

function Parser:parse_number()
   local parts = {}

   -- optional sign
   if self:peek() == "-" then
      table.insert(parts, self:advance())
   end

   -- integer
   local ch = self:peek()

   if ch == "0" then
      table.insert(parts, self:advance())

      if self:peek() >= "0" and self:peek() <= "9" then
	 self:error("leading zeros are not allowed")
      end

   elseif ch >= "1" and ch <= "9" then
      repeat
	 table.insert(parts, self:advance())
	 ch = self:peek()
      until not self:is_digit(ch)
      
   else
      self:error("expected digit")
   end

   -- optional fraction
   if self:peek() == "." then
      table.insert(parts, self:advance())

      if not self:is_digit(self:peek()) then
	 self:error("expected digit after decimal point")
      end

      repeat
	 table.insert(parts, self:advance())
      until not self:is_digit(self:peek())
   end

   -- optional exponent
   if self:peek() == "e" or self:peek() == "E" then
      table.insert(parts, self:advance())

      if self:peek() == "+" or self:peek() == "-" then
	 table.insert(parts, self:advance())
      end

      if not self:is_digit(self:peek()) then
	 self:error("expected digit in exponent")
      end

      repeat
	 table.insert(parts, self:advance())
      until not self:is_digit(self:peek())
   end

   return tonumber(table.concat(parts))
end

function Parser:parse_literal(expected, value)
   for i = 1, #expected do
      local ch = expected:sub(i, i)

      if self:advance() ~= ch then
	 self:error(string.format(
		       "expected '%s'",
		       expected
	 ))
      end
   end

   return value
end


-- decode

local function decode(text)
   local parser = Parser.new(text)

   local value = parser:parse_value()

   parser:skip_whitespace()

   if parser:peek() ~= "" then
      parser:error("unexpected trailing characters")
   end

   return value
end

function json.decode(text)
   return decode(text)
end

function json.encode(value)
   return encode(value, false, 0)
end

function json.pretty(value)
   return encode(value, true, 0)
end

return json
