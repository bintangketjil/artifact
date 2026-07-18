local discover = {}

function discover.run(root)
   root = root or "content"

   local cmd = "./scripts/discover.sh " .. root
   local pipe = assert(io.popen(cmd))

   for file in pipe:lines() do
      print(file)
   end
   pipe:close()
end

return discover
