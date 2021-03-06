local beautiful = require("beautiful")
local widget = require("util.widgets")
local helpers = require("helpers")
local wibox = require("wibox")
local aspawn = require("awful.spawn")

-- beautiful vars
local fg = beautiful.widget_brightness_fg or beautiful.fg_grey
local spacing = beautiful.widget_spacing or 1

-- root
local brightness_root = class()

function brightness_root:init(args)
  -- options
  self.icon = args.icon or beautiful.widget_brightness_icon or { "", beautiful.fg_grey }
  self.mode = args.mode or 'text' -- possible values: text, progressbar, slider
  self.want_layout = args.layout or beautiful.widget_brightness_layout or 'horizontal' -- possible values: horizontal , vertical
  self.bar_size = args.bar_size or 200
  self.bar_colors = args.bar_colors or beautiful.bar_colors or { beautiful.primary, beautiful.alert }
  -- base widgets
  self.wicon = widget.base_icon(self.icon[1], self.icon[2])
  self.wtext = widget.base_text()
  self.widget = self:make_widget()
end

function brightness_root:make_widget()
  if self.mode == "slider" then
    return self:make_slider()
  elseif self.mode == "progressbar" then
    return self:make_progressbar()
  else
    return self:make_text()
  end
end

function brightness_root:make_text()
  local w = widget.box_with_margin(self.want_layout, { self.wicon, self.wtext }, spacing)
  awesome.connect_signal("daemon::brightness", function(brightness)
    self.wtext.markup = helpers.colorize_text(brightness, fg)
  end)
  return w
end

function brightness_root:make_slider()
  local slider = widget.make_a_slider(1)
  local w = widget.add_icon_to_slider(slider, self.icon[1], self.icon[2], self.want_layout)
  -- set level
  slider:connect_signal('property::value', function()
    aspawn.with_shell('light -S ' .. slider.value)
  end)
  -- get current level
  awesome.connect_signal("daemon::brightness", function(brightness)
    slider.minimum = 1
    slider:set_value(brightness)
  end)
  return w
end

function brightness_root:make_progressbar()
  local p = widget.make_progressbar(_, self.bar_size, { self.bar_colors[1][1], self.bar_colors[2] })
  local w = widget.progressbar_layout(p, self.want_layout)
  local space = self.want_layout == "horizontal" and 8 or 2
  awesome.connect_signal("daemon::brightness", function(brightness)
    p.value = brightness
  end)
  return widget.box_with_margin(self.want_layout, { self.wicon, w }, space)
end

-- herit
local brightness_widget = class(brightness_root)

function brightness_widget:init(args)
  brightness_root.init(self, args)
  return self.widget
end

return brightness_widget
