--- {{{ Libaries
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local vicious = require("vicious")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

-- Widget Libaries
local volume_control = require("Libaries/volume-control")

-- Load Debian menu entries
require("debian.menu")
--- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/powerarrow-darker/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "terminator"
browser = "google-chrome"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
tagnum = 5

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.spiral.dwindle, 
    awful.layout.suit.fair,
    awful.layout.suit.spiral, 
    awful.layout.suit.floating,
    awful.layout.suit.max.fullscreen
    }
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
local function screen_backgrounds()
    for s = 1, screen.count() do
        for t = 1, 6 do
            tags[s][t]:connect_signal("property::selected", function (tag)
                if not tag.selected then return end
                theme.wallpaper = "/home/willroy/.config/awesome/themes/powerarrow-darker/wallpaper/" .. t .. ".\png"
                gears.wallpaper.maximized(beautiful.wallpaper, s, true)
                
            end)
        end
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "1", "2", "3", "4", "5", "6" }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
    {"edit config", "terminator -e vim ~/.config/awesome/rc.lua"},
    {"edit theme", "terminator -e vim ~/.config/awesome/themes/powerarrow-darker/theme.lua"},
    {"restart", awesome.restart },
    {"quit", awesome.quit },
    {"reboot", "reboot"},
    {"power off", "poweroff"}
}

mymainmenu = awful.menu({ items = { 
  	{ " awesome",           myawesomemenu, beautiful.awesome_icon },
  	{ " terminal",          terminal, beautiful.terminal_icon},
  	{ " chrome",          browser},
        
        
} })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
--- }}}  

--- {{{ Widgets
--function execute_command(command)
--    local fh = io.popen(command)
--    local str = ""
--    for i in fh:lines() do
--       str = str .. i
--    end
--    io.close(fh)
--    return str
-- end
-- 
-- -- Helper function to build all you need
-- function widget_with_timeout(command, seconds)
--   local object = {}
--   object.command = command
--   object.widget = wibox.widget.textbox()
--   
--   object.update = function ()
--     local result = execute_command(object.command)
--     object.widget.text = " " .. awful.util.escape(result) .. " "
--   end
--[[
  object.timer = timer({ timeout = seconds })
  object.timer:add_signal("timeout", object.update)
  object.timer:start()

  object.update() -- Initialize immediately
  return object
end]]

-- Create a textclock widget
mytextclock = awful.widget.textclock()
mytextclockbg = wibox.widget.background(mytextclock, "#313131")
mytextclock_t = awful.tooltip({
    objects = { mytextclock },
    timer_function = function()
        return os.date("Second: %S") 
end,

})

--Battery
batteryicon = wibox.widget.textbox('⚡ ')
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, "  $2% ", 17, "BAT0")
mybattery_t = awful.tooltip({
    objects = { mybattery },
    timer_function = function()
            return "Insert information here"
        end,
    })

-- --micmute
-- micicon =--[[ ]]widget_with_timeout(" amixer | grep Capture | grep Front | grep '\[on\]' -o | sed -n '1!p'", 3)

    
--Volume
soundicon = wibox.widget.textbox('♬  ')
volumecfg = volume_control({})

--Separators
spr = wibox.widget.textbox(' ')
sprlight = wibox.widget.background(spr, "#313131")
arrl = wibox.widget.imagebox()
arrl:set_image(beautiful.arrl)
arrl_dl = wibox.widget.imagebox()
arrl_dl:set_image(beautiful.arrl_dl)
arrl_ld = wibox.widget.imagebox()
arrl_ld:set_image(beautiful.arrl_ld)

--get icons next to windows
theme.tasklist_disable_icon = true

--- }}}

--- {{{ Wibox

-- Create a wibox for each screen and add it
local taskbar_enabled = true
if taskbar_enabled then
    mywibox = {}
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
                        awful.button({ }, 1, function (c)
                                                if c == client.focus then
                                                    c.minimized = true
                                                else
                                                    -- Without this, the following
                                                    -- :isvisible() makes no sense
                                                    c.minimized = false
                                                    if not c:isvisible() then
                                                        awful.tag.viewonly(c:tags()[1])
                                                    end
                                                    -- This will also un-minimize
                                                    -- the client, if needed
                                                    client.focus = c
                                                    c:raise()
                                                end
                                            end),
                        awful.button({ }, 3, function ()
                                                if instance then
                                                    instance:hide()
                                                    instance = nil
                                                else
                                                    instance = awful.menu.clients({
                                                        theme = { width = 250 }
                                                    })
                                                end
                                            end),
                        awful.button({ }, 4, function ()
                                                awful.client.focus.byidx(1)
                                                if client.focus then client.focus:raise() end
                                            end),
                        awful.button({ }, 5, function ()
                                                awful.client.focus.byidx(-1)
                                                if client.focus then client.focus:raise() end
                                            end))

                                            

    for s = 1, screen.count() do
        -- Create a promptbox for each screen
        mypromptbox[s] = awful.widget.prompt()
        -- Create an imagebox widget which will contains an icon indicating which layout we're using.
        -- We need one layoutbox per screen.
        mylayoutbox[s] = awful.widget.layoutbox(s)
        mylayoutbox[s]:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
                                
        -- Create a taglist widget
        mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

        -- Create a tasklist widget
        mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

        -- Create the wibox
        mywibox[s] = awful.wibox({ position = "top", screen = s, height = 20 })

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        --left_layout:add(mylauncher)
        left_layout:add(spr)
        left_layout:add(mytaglist[s])
        left_layout:add(mypromptbox[s])
        left_layout:add(spr)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        if s == 1 then right_layout:add(wibox.widget.systray()) end
        
        right_layout:add(spr)
        right_layout:add(arrl_ld)
        right_layout:add(sprlight)
        right_layout:add(arrl_dl)
        --right_layout:add(volumecfg.widget)
    --     right_layout:add(micicon)
        right_layout:add(soundicon)
        right_layout:add(volumecfg.widget)
        right_layout:add(arrl_ld)
        right_layout:add(mytextclockbg)
        right_layout:add(arrl_dl)
        right_layout:add(mybattery)
        right_layout:add(batteryicon)
        
        -- Now bring it all together (with the tasklist in the middle)
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_middle(mytasklist[s])
        layout:set_right(right_layout)

        mywibox[s]:set_widget(layout)
    end
                            end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    
    -- Top Row
    awful.key({modkey,}, "XF86AudioMute", function() awful.util.spawn("amixer set Capture toggle") 
key=os.execute('amixer | grep Capture | grep [[on]] | grep Front') 
if key == "" then
    keytrue = false
else
    keytrue = true
end

micicon = wibox.widget.textbox(tostring(keytrue))end),
    awful.key({}, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer -q sset Master 3%+") end),
    awful.key({}, "XF86AudioLowerVolume", function() awful.util.spawn("amixer -q sset Master 3%-") end),
    awful.key({}, "XF86AudioMute",        function() awful.util.spawn("amixer -D pulse set Master toggle") end),
    awful.key({}, "XF86MonBrightnessUp", function() awful.util.spawn("xbacklight -inc 10 -time 0.5") end),
    awful.key({}, "XF86MonBrightnessDown", function() awful.util.spawn("xbacklight -dec 10 -time 0.5") end),
    -- Touchpad
    awful.key({ modkey,   "Shift" }, "/", function () awful.util.spawn("xinput set-prop 13 'Device Enabled' 0") end),
    awful.key({ modkey, "Control" }, "/", function () awful.util.spawn("xinput set-prop 13 'Device Enabled' 1") end),
    awful.key({ modkey, "Shift"   }, 'o',
    function ()
        local allclients = function (c)
            return true
        end
        for c in awful.client.iterate(allclients) do
            local ctag = awful.tag.getidx(c:tags()[1])
            local cscreen = c.screen + 1
            if cscreen > screen.count() then
                cscreen = 1
            end
            awful.client.movetotag(tags[cscreen][ctag], c)
        end
    end),
    -- Tag Manipulation
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    -- Windows
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    -- Menu
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
        
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
                
        
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
                  
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    elseif not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count change
        awful.placement.no_offscreen(c)
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
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
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

--{{{ Tag Wallpapers
screen_backgrounds()
    -- }}}

naughty.config.presets.spotify = {callback = function() return false end}
table.insert(naughty.config.mapping, {{appname = "Spotify"}, naughty.config.presets.spotify})
