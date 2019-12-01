local beautiful = require("beautiful")
local theme = {}

theme.name = "morpho"

local theme_dir = os.getenv("HOME") .. "/.config/awesome/themes/"
beautiful.init( theme_dir .. theme.name .. "/theme.lua" )

local bar = require("bars."..theme.name)

return theme