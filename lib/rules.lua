local Rules = {}

local function extend(base, extra)
   local rule = {}

   for key, value in pairs(base) do
      rule[key] = value
   end

   if extra then
      for key, value in pairs(extra) do
	 rule[key] = value
      end
   end

   return rule
end

Rules.default = {
   required = {
      "title",
      "date",
      "category",
      "type",
   },

   optional = {
      "author",
      "summary",
      "tags",
      "status",
      "updated",
      "slug",
   },
}

-- top level
Rules.page = extend(Rules.default, {
		       required = {
			  "title",
			  "category",
		       },
})

-- type
Rules.writings = {
   notes = Rules.default,
   essays = Rules.default,
}

Rules.self = {
   ["log-entry"] = Rules.default,
}

return Rules
