local Document = require "document"

local Reader = {}

function Reader.read(path)
   local document = Document.new(path)

   local file = assert(
      io.open(path, "r"),
      "failed to open file: " .. path
   )

   document.source = file:read("*a")

   file:close()

   return document
end

return Reader
