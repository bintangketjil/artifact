local Discover = require "discover"
local Reader = require "reader"
local Metadata = require "metadata"
local Normalize = require "normalize"
local Validator = require "validator"

local Manifest = {}

function Manifest.build(root)
   root = root or "content"
   
   local manifest = {}
   local paths = Discover.run(root)

   for _, path in ipairs(paths) do
      local document = Reader.read(path)

      Metadata.extract(document)
      Normalize.document(document)
      Validator.document(document)

      table.insert(manifest, document)
   end

   return manifest
end

return Manifest
