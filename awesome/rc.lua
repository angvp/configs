-----------------------------
-- AwesomeWM configuration --
--         3.5-rc1         --
--      <tdy@gmx.com>      --
-----------------------------

local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init(awful.util.getdir("config") .. "/themes/dust/theme.lua")
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local wi = require("wi")

-- {{{ Error handling
-- Startup
if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
      title = "Oops, there were errors during startup!",
      text = awesome.startup_errors })
end

-- Runtime
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
      if in_error then return end
      in_error = true

      naughty.notify({ preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = err })
      in_error = false
    end)
end
-- }}}

-- {{{ Variables
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
altkey = "Mod1"
-- }}}

-- {{{ Layouts
local layouts =
{
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.magnifier
}
-- }}}

-- {{{ Naughty presets
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Monaco 10"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 256
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 2
naughty.config.defaults.hover_timeout = nil
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
  for s = 1, screen.count() do
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)
  end
end
-- }}}

-- {{{ Tags
tags = {
  names = {"terms", "firefox", "dev", "chrome", "other", "virtual", "im", "irc", "media" }, 
  layouts = { layouts[2], layouts[10], layouts[2], layouts[2], layouts[2],
    layouts[1], layouts[10], layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Shutdown
mylauncher = wibox.widget.imagebox()
mylauncher:set_image(beautiful.awesome_icon)
mylauncher:buttons(awful.util.table.join(
  awful.button({ }, 1, function()
      awful.util.spawn_with_shell("i3lock -d -p default -c " .. beautiful.bg_focus:gsub("#",""))
    end),
  awful.button({ modkey }, 1, function()
      awful.util.spawn_with_shell("reboot.sh")
    end),
  awful.button({ modkey }, 3, function()
      awful.util.spawn_with_shell("shutdown.sh")
    end)
))
-- }}}

-- Menubar
menubar.utils.terminal = terminal

-- Clock
mytextclock = awful.widget.textclock("<span color='" .. beautiful.fg_em .. "'> %a %m/%d</span> @ %I:%M %p")

-- {{{ Wiboxes
mywibox = {}
mygraphbox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
  awful.button({ }, 1, awful.tag.viewonly),
  awful.button({ modkey }, 1, awful.client.movetotag),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, awful.client.toggletag),
  awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function(c)
      if c == client.focus then
        c.minimized = true
      else
        c.minimized = false
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
      end
    end),
  awful.button({ }, 3, function()
      if instance then
        instance:hide()
        instance = nil
      else
        instance = awful.menu.clients({ width=250 })
      end
    end),
  awful.button({ }, 4, function()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
    end),
  awful.button({ }, 5, function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end))

--{{{ Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", "" , "EN" }, { "es", "" , "ES" } } 
kbdcfg.current = 1  -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
kbdcfg.switch = function ()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = kbdcfg.layout[kbdcfg.current]
  kbdcfg.widget:set_text(" " .. t[3] .. " ")
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
end



for s = 1, screen.count() do
  mypromptbox[s] = awful.widget.prompt()

  -- Layoutbox
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function() awful.layout.inc(layouts, 1) end),
      awful.button({ }, 3, function() awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function() awful.layout.inc(layouts, 1) end),
      awful.button({ }, 5, function() awful.layout.inc(layouts, -1) end)))

  -- Taglist
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Tasklist
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Wibox
  mywibox[s] = awful.wibox({ position = "top", height = 24, screen = s })

  local left_wibox = wibox.layout.fixed.horizontal()
  left_wibox:add(mytaglist[s])
  left_wibox:add(space)
  left_wibox:add(mypromptbox[s])
  left_wibox:add(mylayoutbox[s])
  left_wibox:add(space)

  local right_wibox = wibox.layout.fixed.horizontal()
  right_wibox:add(space)
  if s == 1 then right_wibox:add(wibox.widget.systray()) end
  right_wibox:add(baticon)
  right_wibox:add(batpct)
  right_wibox:add(kbdcfg.widget)
  right_wibox:add(volicon)
  right_wibox:add(volpct)
  right_wibox:add(volspace)

  local wibox_layout = wibox.layout.align.horizontal()
  wibox_layout:set_left(left_wibox)
  wibox_layout:set_middle(mytasklist[s])
  wibox_layout:set_right(right_wibox)

  mywibox[s]:set_widget(wibox_layout)

  -- Graphbox
  mygraphbox[s] = awful.wibox({ position = "bottom", height = 22, screen = s })

  local right_graphbox = wibox.layout.fixed.horizontal()
  right_graphbox:add(weather)
  right_graphbox:add(mytextclock)

  local graphbox_layout = wibox.layout.align.horizontal()
  graphbox_layout:set_right(right_graphbox)

  mygraphbox[s]:set_widget(graphbox_layout)
end
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
  awful.key({ modkey, }, "Left", awful.tag.viewprev ),
  awful.key({ modkey, }, "Right", awful.tag.viewnext ),
  awful.key({ modkey, }, "Escape", awful.tag.history.restore),

  awful.key({ altkey, }, "Tab",
    function()
      awful.client.focus.byidx( 1)
      if client.focus then client.focus:raise() end
    end),
  awful.key({ modkey, "Shift" }, "Tab",
    function()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
    end),

  -- Layout manipulation
  awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx( 1) end),
  awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end),
  awful.key({ modkey, }, "Tab", function() awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Shift" }, "Tab", function() awful.screen.focus_relative(-1) end),
  awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey, }, "p",
    function()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end),

  -- Standard program
  awful.key({ modkey, }, "Return", function() awful.util.spawn(terminal) end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Shift" }, "q", awesome.quit),

  awful.key({ modkey, }, "l", function() awful.tag.incmwfact( 0.05) end),
  awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, }, "k", function() awful.client.incwfact( 0.03) end),
  awful.key({ modkey, }, "j", function() awful.client.incwfact(-0.03) end),
  awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster( 1) end),
  awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1) end),
  awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol( 1) end),
  awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1) end),
  awful.key({ modkey, }, "space", function() awful.layout.inc(layouts, 1) end),
  awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(layouts, -1) end),

  awful.key({ modkey, "Control" }, "n", awful.client.restore),

  -- Prompt
  awful.key({ modkey }, "r", function() mypromptbox[mouse.screen]:run() end),

  awful.key({ modkey }, "x",
    function()
      awful.prompt.run({ prompt = "Run Lua code: " },
        mypromptbox[mouse.screen].widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end),

  -- {{{ Tag 0
  awful.key({ modkey }, 0,
    function()
      local screen = mouse.screen
      if tags[screen][10].selected then
        awful.tag.history.restore(screen)
      elseif tags[screen][10] then
        awful.tag.viewonly(tags[screen][10])
      end
    end),
  awful.key({ modkey, "Control" }, 0,
    function()
      local screen = mouse.screen
      if tags[screen][10] then
        tags[screen][10].selected = not tags[screen][10].selected
      end
    end),
  awful.key({ modkey, "Shift" }, 0,
    function()
      if client.focus and tags[client.focus.screen][10] then
        awful.client.movetotag(tags[client.focus.screen][10])
      end
    end),
  awful.key({ modkey, "Control", "Shift" }, 0,
    function()
      if client.focus and tags[client.focus.screen][10] then
        awful.client.toggletag(tags[client.focus.screen][10])
      end
    end)
  -- }}}
)

clientkeys = awful.util.table.join(
  awful.key({ modkey, }, "f", function(c) c.fullscreen = not c.fullscreen end),
  awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end),
  awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle ),
  awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey, }, "o", awful.client.movetoscreen ),
  awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end),
  awful.key({ modkey, }, "n",
    function(c)
      c.minimized = true
    end),

  -- Maximize
  awful.key({ modkey, }, "m",
    function(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical = not c.maximized_vertical
    end),

  -- Menubar
  awful.key({ modkey }, "p", function() menubar.show() end),

  -- Brightness
  awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn("xbacklight -dec 15")        end),
  awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn("xbacklight -inc 15")        end),

  -- Volume
  awful.key({ }, "XF86AudioRaiseVolume",  function () awful.util.spawn("amixer set Master 7%+")     end),
  awful.key({ }, "XF86AudioLowerVolume",  function () awful.util.spawn("amixer set Master 7%-")     end),
  awful.key({ }, "XF86AudioMute",         function () awful.util.spawn("amixer sset Master toggle") end)
 
)

keynumber = 0
for s = 1, screen.count() do
  keynumber = math.min(9, math.max(#tags[s], keynumber))
end

for i = 1, keynumber do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i].selected then
          awful.tag.history.restore(screen)
        elseif tags[screen][i] then
          awful.tag.viewonly(tags[screen][i])
        end
      end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
      function()
        local screen = mouse.screen
        if tags[screen][i] then
          awful.tag.viewtoggle(tags[screen][i])
        end
      end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.movetotag(tags[client.focus.screen][i])
        end
      end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
      function()
        if client.focus and tags[client.focus.screen][i] then
          awful.client.toggletag(tags[client.focus.screen][i])
        end
      end))
end

clientbuttons = awful.util.table.join(
  awful.button({ }, 1, function(c) client.focus = c; c:raise() end),
  awful.button({ modkey }, 1, awful.mouse.client.move),
  awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
  { rule = { },
    properties = { border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      keys = clientkeys,
      buttons = clientbuttons } },
  { rule = { class = "MPlayer" },
    properties = { floating = true, tag = tags[1][9] } },
  { rule = { class = "Smplayer" },
    properties = { floating = true, tag = tags[1][9] } },
  { rule = { class = "Pidgin" },
    properties = { floating = true, tag = tags[1][7] } },
  { rule = { class = "Skype" },
    properties = { floating = true, tag = tags[1][7] } },
  { rule = { class = "Firefox" },
    properties = { tag = tags[1][2] } },
  { rule = { class = "Firefox", instance = "Download" },
    properties = { floating = true } },
  { rule = { class = "Firefox", instance = "Browser" },
    properties = { floating = true } },
  { rule = { class = "Firefox", instance = "Toplevel" },
    properties = { floating = true } },
  { rule = { class = "Firefox", instance = "Places" },
    properties = { floating = true } },
  { rule = { class = "Thunderbird", instance = "Mail" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunderbird", instance = "Calendar" },
    properties = { floating = true, above = true } },
  { rule = { class = "Thunderbird", instance = "Msgcompose" },
    properties = { floating = true, above = true } },
  { rule = { class = "Spacefm" },
    properties = { tag = tags[1][5] } },
  { rule = { class = "Chromium" },
    properties = { tag = tags[1][4] } },
  { rule = { class = "Gimp-2.8" },
    properties = { floating = true, tag = tags[1][8] } }
}
-- }}}

-- Mouse bindings
kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)

-- {{{ Signals
client.connect_signal("manage", function(c, startup)
    c.size_hints_honor = false

    -- Sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
          client.focus = c
        end
      end)

    if not startup then
      -- Set the windows at the slave
      awful.client.setslave(c)

      -- Put windows in a smart way, only if they does not set an initial position
      if not c.size_hints.user_position and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
      end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))

      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      local title = awful.titlebar.widget.titlewidget(c)
      title:buttons(awful.util.table.join(
          awful.button({ }, 1, function()
              client.focus = c
              c:raise()
              awful.mouse.client.move(c)
            end),
          awful.button({ }, 3, function()
              client.focus = c
              c:raise()
              awful.mouse.client.resize(c)
            end)
      ))

      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(title)

      awful.titlebar(c):set_widget(layout)
    end
  end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
