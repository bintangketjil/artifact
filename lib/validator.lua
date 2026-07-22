local Rules = require "rules"

local Validator = {}

function Validator.error(document, field, message)
   table.insert(document.diagnostics, {
		   severity = "error",
		   field = field,
		   message = message,
   })
end

function Validator.warning(document, field, message)
   table.insert(document.diagnostics, {
		   severity = "warning",
		   field = field,
		   message = message,
   })
end

function Validator.document(document)
   Validator.metadata(document)

   return document
end

function Validator.metadata(document)
   local metadata = document.metadata

   Validator.required(document, metadata, "category")
   Validator.required(document, metadata, "type")

   local category = metadata.category
   local type = metadata.type

   if not category or not type then
      return
   end

   local group = Rules[category]

   if not group then
      Validator.error(
	 document,
	 "category",
	 string.format("unknow category '%s'", category)
      )

      return
   end

   local rule

   if group.required then
      rule = group
   else
      Validator.required(document, metadata, "type")

      if not metadata.type then
	 return
      end

      rule = group[metadata.type]

      if not rule then
	 Validator.error(
	    document,
	    "type",
	    string.format(
	       "unknow type '%s' for category '%s'",
	       metadata.type,
	       category
	    )
	 )
	 return
      end
   end
   
   for _, field in ipairs(rule.required) do
      Validator.required(document, metadata, field)
   end
end

function Validator.required(document, metadata, field)
   if metadata[field] == nil then
      Validator.error(
	 document,
	 field,
	 string.format("missing required metadata '%s'", field)
      )
   end
   
end

return Validator
