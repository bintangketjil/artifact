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

   local category = metadata.category

   if not category then
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

   -- top level
   if group.required then
      rule = group
   else
      Validator.required(document, metadata, "type")

      local type = metadata.type

      if not type then
	 return
      end

      rule = group[type]

      if not rule then
	 Validator.error(
	    document,
	    "type",
	    string.format(
	       "unknow type '%s' for category '%s'",
	       type,
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
