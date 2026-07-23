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

local Allowed = {
   title = true,
   date = true,
   category = true,
   type = true,

   author = true,
   summary = true,
   description = true,

   tags = true,
   status = true,

   updated = true,
   slug = true,

   lang = true,
   related = true,
   references = true,

   created = true,
   latest = true,
   subtitle = true,
   ["title-suffix"] = true,

}

function Validator.fields(document)
   for field in pairs(document.metadata) do
      if not Allowed[field] then
	 Validator.warning(
	    document,
	    field,
	    string.format("unknown metadata '%s'", field)
	 )
      end
   end
end

function Validator.document(document)
   Validator.metadata(document)
   Validator.fields(document)

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
	 string.format("unknown category '%s'", category)
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
	       "unknown type '%s' for category '%s'",
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
