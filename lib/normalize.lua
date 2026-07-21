local Normalize = {}

function Normalize.document(document)
   Normalize.metadata(document.metadata)

   return document
end

function Normalize.metadata(metadata)
   if metadata.date then
      metadata.date = Normalize.date(metadata.date)
   end

   if metadata.lang then
      metadata.lang = Normalize.lang(metadata.lang)
   end
end

function Normalize.date(date)
   local y, m, d = date:match("^(%d+)%-(%d+)%-(%d+)$")

   if not y then
      return date
   end

   return string.format(
      "%04d-%02d-%02d",
      tonumber(y),
      tonumber(m),
      tonumber(d)
   )
end

function Normalize.lang(lang)
   local language, region = lang:match("^([A-Za-z]+)%-([A-Za-z]+)$")

   if language and region then
      return language:lower() .. "-" .. region:upper()
   end

   return lang:lower()
end

return Normalize
