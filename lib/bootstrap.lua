local root = debug.getinfo(1).source
   :match("@(.*/)")
   :gsub("/lib/$", "")

package.path = package.path
   .. ";" .. root .. "/lib/?.lua"
   .. ";" .. root .. "/lib/?/init.lua"
