local Metadata = {}

local json = require "json"

-- TODO:
-- implement metadata extractor
function Metadata.extract(document)
   local command = string.format(
      "pandoc %q --lua-filter=scripts/reader.lua",
      document.path
   )

   local pipe = assert(
      io.popen(command),
      "failed to run pandoc metadata reader"
   )

   local output = pipe:read("*a")
   pipe:close()

   document.metadata = json.decode(output)

   return document
end

return Metadata
