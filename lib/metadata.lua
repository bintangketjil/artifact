local Metadata = {}

local json = require "json"

local FILTER = "scripts/extract-metadata.lua"

function Metadata.extract(document)
   local command = string.format(
      "pandoc %q --lua-filter=%q",
      document.path,
      FILTER
   )

   local pipe = assert(
      io.popen(command),
      "failed to run pandoc metadata reader"
   )

   local output = pipe:read("*a")
   pipe:close()

   if output == "" then
      error("metadata extraction returned empty output for " .. document.path)
   end
   
   document.metadata = json.decode(output)

   return document
end

return Metadata
