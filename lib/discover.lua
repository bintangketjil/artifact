local Discover = {}


function Discover.run(root)
   root = root or "content"

   local command = string.format(
      "./scripts/discover.sh %q",
      root
   )

   local pipe = assert(
      io.popen(command),
      "failed to execute discover.sh"
   )

   local files = {}

   for file in pipe:lines() do
      table.insert(files, file)
   end
   
   local ok = pipe:close()

   if not ok then
      error("discover failed")
   end

   return files
end

return Discover
