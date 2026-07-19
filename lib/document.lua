local Document = {}

function Document.new(path)
   return {
      path = path,
      source = "",
      metadata = {},
      tokens = {},
      diagnostics = {},
      output = {},
   }
end

return Document
