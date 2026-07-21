local Reader = require "reader"
local Metadata = require "metadata"
local Normalize = require "normalize"

local Manifest = {}

function Manifest.build(paths)
   local manifest = {}

   for _, path in ipairs(paths) do
      local document = Reader.read(path)

      Metadata.extract(document)
      Normalize.document(document)

      table.insert(manifest, document)
      -- table.insert(manifest, {
      -- 		      path = document.path,
      -- 		      metadata = document.metadata,
      -- })
   end

   return manifest
end

return Manifest
