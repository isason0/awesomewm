-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local kone = require("kone")
local notik = require("notik")
local visib = 0
local kvisib = 1
local trayV = 1
local lpadding = 0
local bpadding = 65

-- Brightness check command
local brcmd = [[
    sh -c "
    /usr/bin/xbacklight -get
    "]]
-- Volume check command
local vmcmd = [[
    sh -c "
    /usr/bin/pulsemixer --get-volume | awk '{print $1}'
    "]]
-- Mute check command
local mutecmd = [[
    sh -c "
    /usr/bin/pulsemixer --get-mute
    "]]


local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua",
    os.getenv("HOME"), "default")
beautiful.init(theme_path)

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = "nvim"
editor_cmd = terminal .. " -e " .. editor
browser = "firefox-bin"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    -- awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

--Gaps & padding
beautiful.useless_gap = 15
awful.screen.padding(screen[1], {bottom = 65})

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    local names = { "", "", "ﱘ", "", ""}
    local l = awful.layout.suit
    local layouts = { l.tile, l.tile, l.tile, l.max, l.floating, }
    awful.tag(names, s, layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    -- Not in use currently
    --s.mytaglist = awful.widget.taglist {
        --screen  = s,
        --filter  = awful.widget.taglist.filter.all,
        --buttons = taglist_buttons,
        --style = {
            --squares_resize = false
        --},
        --layout = {
            --spacing = 8,
            --layout = wibox.layout.fixed.horizontal
        --},
--
--
--
        --widget_template = {
                --{
                    --{
                        --{
                            --{
                                --{
                                    --id     = 'index_role',
                                    --widget = wibox.widget.textbox,
                                --},
                                --margins = 4,
                                --widget  = wibox.container.margin,
                            --},
                            --bg     = '#dddddd',
                            --shape = gears.shape.circle,
                            --widget = wibox.container.background,
                        --},
                        --{
                            --{
                                --id     = 'icon_role',
                                --widget = wibox.widget.imagebox,
                            --},
                            --margins = 2,
                            --widget  = wibox.container.margin,
                        --},
                        --{
                            --id     = 'text_role',
                            --widget = wibox.widget.textbox,
                        --},
                        --layout = wibox.layout.fixed.horizontal,
                    --},
                    --left  = 18,
                    --right = 18,
                    --widget = wibox.container.margin
                --},
                --id     = 'background_role',
                --widget = wibox.container.background,
            --},
--
--
            --buttons = taglist_buttons
    --}


    -- Define a different background color for each tag when selected
    -- (not in use)
    --tag.connect_signal(
    --"property::selected",
    --function(t)
        --if t.selected then
            --beautiful.taglist_bg_focus = beautiful.tag_focus_background_colors[t.index]
            ----beautiful.taglist_fg_focus = beautiful.tag_focus_foreground_colors[t.index]
        --end
    --end)

    -- Create a tasklist widget
    --s.mytasklist = awful.widget.tasklist {
        --screen  = s,
        --filter  = awful.widget.tasklist.filter.currenttags,
        --buttons = tasklist_buttons,
--
    --layout   = {
        --spacing_widget = {
            --{
                --forced_width  = 5,
                --forced_height = 24,
                --thickness     = 1,
                --color         = '#777777',
                --widget        = wibox.widget.separator
            --},
            --valign = 'center',
            --halign = 'center',
            --widget = wibox.container.place,
        --},
        --spacing = 1,
        --layout  = wibox.layout.fixed.horizontal
    --},
    ---- Notice that there is *NO* wibox.wibox prefix, it is a template,
    ---- not a widget instance.
    --widget_template = {
        --{
            --wibox.widget.base.make_widget(),
            --forced_height = 5,
            --id            = 'background_role',
            --widget        = wibox.container.background,
        --},
        --{
            --{
                --id     = 'clienticon',
                --widget = awful.widget.clienticon,
            --},
            --margins = 5,
            --widget  = wibox.container.margin
        --},
        --nil,
        --create_callback = function(self, c, index, objects) --luacheck: no unused args
            --self:get_children_by_id('clienticon')[1].client = c
        --end,
        --layout = wibox.layout.align.vertical,
    --},
--}

    -- Create the wibox bar
    -- Currently i have none in use

    --function wibar_cShape(cr, w, h)
        --gears.shape.rounded_rect(cr, w, h, 10)
    --end

    --s.mywibox = awful.wibar({ position = "top",
    --align = "center",
    --screen = s,
    --height = 35, width = 295,
    --shape = wibar_cShape })

    ---- Add widgets to the wibox
    --s.mywibox:setup {
        --layout = wibox.layout.fixed.horizontal,
        --{ -- Left widgets
            --layout = wibox.layout.fixed.horizontal,
            --wibox.layout.margin(
                --s.mylayoutbox,
            --10, 10, 10, 10),
            --mylauncher,
            --s.mytaglist,
            --s.mypromptbox,
        --},
        ----s.mytasklist, -- Middle widget
        --{ -- Right widgets
            --layout = wibox.layout.align.horizontal,
            ----mytextclock,
            ----mykeyboardlayout,
            --wibox.layout.margin(
                --wibox.widget.systray(),
            --8, 8, 8, 8 ),
        --},
    --}


    -- Create the second wibox bar (not in use)

--    s.mywibox2 = awful.wibar({ position = "bottom", screen = s, height = 35, width = 230 })
--
--    -- Add widgets to the wibox
--    s.mywibox2:setup {
--        layout = wibox.layout.align.horizontal,
--        { -- Left widgets
--            layout = wibox.layout.fixed.horizontal,
----            wibox.layout.margin(
----                s.mylayoutbox,
----            10, 10, 10, 10),
--            --mylauncher,
--                s.mytasklist,
----            s.mytaglist,
----            s.mypromptbox,
--        },
--        --s.mytasklist, -- Middle widget
--        { -- Right widgets
--            layout = wibox.layout.align.horizontal,
----            mytextclock,
----            mykeyboardlayout,
--            wibox.layout.margin(
--                wibox.widget.systray(),
--            8, 8, 8, 8 ),
--        },
--    }



end)






-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    --awful.button({ }, 3, function () mymainmenu:toggle() end),
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    -- Brightness :
    -- up
    awful.key({ }, "XF86MonBrightnessUp", function ()
        awful.spawn.with_shell("/usr/bin/xbacklight -inc 2")

        awful.spawn.with_line_callback(brcmd, {
            stdout = function(line)
                br_tex.markup = line
                local brightN = tonumber(line)
                br_progressbar.value = brightN
            end,
        })
    end),
    -- down
    awful.key({ }, "XF86MonBrightnessDown", function ()
        awful.spawn.with_shell("/usr/bin/xbacklight -dec 2")

        awful.spawn.with_line_callback(brcmd, {
            stdout = function(line)
                br_tex.markup = line
                local brightN = tonumber(line)
                br_progressbar.value = brightN
            end,
        })

    end),

    -- Volume :
    -- up
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ +2000")

        awful.spawn.with_line_callback(vmcmd, {
            stdout = function(line)
                vm_tex.markup = line
                local volumE = tonumber(line)
                vm_progressbar.value = volumE
            end,
        })

    end),
    -- down
    awful.key({ }, "XF86AudioLowerVolume", function()
        awful.spawn.with_shell("pactl set-sink-volume @DEFAULT_SINK@ -2000")

        awful.spawn.with_line_callback(vmcmd, {
            stdout = function(line)
                vm_tex.markup = line
                local volumE = tonumber(line)
                vm_progressbar.value = volumE
            end
        })

    end
    ),
    --mute
    awful.key({ }, "XF86AudioMute", function()
        awful.spawn.with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")


        awful.spawn.with_line_callback(mutecmd, {
            stdout = function(line)
                local mutE = tonumber(line)

                if mutE == 1 then
                    vm_ico.markup = "婢"
                else
                    vm_ico.markup = "墳"
                end
            end
        })


    end
    ),


    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    --awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              --{description = "show main menu", group = "awesome"}),

    -- Layout manipulation

    awful.key({ modkey, "Shift"  }, "j",
    function ()
        awful.client.swap.global_bydirection("down")
        end,
        {description = "swap window by direction down", group = "client"}),

    awful.key({ modkey, "Shift"  }, "k",
    function ()
        awful.client.swap.global_bydirection("up")
        end,
        {description = "swap window by direction up", group = "client"}),

    awful.key({ modkey, "Shift"  }, "h",
    function()
        awful.client.swap.global_bydirection("right")
        end,
        {description = "swap window by direction right", group = "client"}),

    awful.key({ modkey, "Shift"  }, "l",
    function()
        awful.client.swap.global_bydirection("left")
        end,
        {description = "swap window by direction left", group = "client"}),

    -- Dock (kone)

    awful.key({ modkey, "Shift" }, "d", function (kone)
        if kvisib == 0 then
            konebox.visible = true
            bpadding = 65
            awful.screen.padding(screen[1], {bottom = bpadding, left = lpadding})
            kvisib = 1
        elseif kvisib == 1 then
            konebox.visible = false
            bpadding = 0
            awful.screen.padding(screen[1], {bottom = bpadding, left = lpadding})
            kvisib = 0
        end
    end,
        {description = "show / hide dock", group = "kone"}),

    awful.key({ modkey }, "d", function(kone)
        if matchers == false then
            matchers = true
            mM_imagebox.visible = true
            konebox.y = 1000
        else
            matchers = false
            mM_imagebox.visible = false
            konebox.y = 1020
        end
    end,
        {description = "toggle matcher mode", group = "kone"}),

    -- Stat screen (notik)

    awful.key({ modkey, }, "Tab", function (notik)
        if visib == 0 then
            notikbox.visible = true
            lpadding = 250
            awful.screen.padding(screen[1], {bottom = bpadding, left = lpadding})
            visib = 1
        elseif visib == 1 then
            notikbox.visible = false
            lpadding = 0
            awful.screen.padding(screen[1], {bottom = bpadding, left = lpadding})
            visib = 0
        end

    end,
        {description = "show / hide statbar", group = "notik"}),

    awful.key({ modkey, }, "r", function (notik)
        if trayV == 0 then
            tray_cont.visible = true
            trayV = 1
        else
            tray_cont.visible = false
            trayV = 0
        end
    end,
        {description = "show / hide systray", group = "notik"}),

    -- Focus clients

    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- Standard program

    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,  "Shift"  }, "f",      function () awful.spawn(browser) end,
              {description = "open browser",   group = "launcher"}),
    awful.key({ modkey, "Control" }, "b", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control", "Shift"   }, "b", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key( {modkey, }, "p", function()
        awful.spawn.with_shell("dmenu_run -c -l 16")
    end,
    { description = "run dmenu", group = "launcher" }),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}) )

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Shift" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"}) )

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    ) end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end) )

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
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
        --  "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {size = 40}) : setup {
        { -- Left
            --awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                --align  = "center",
                --widget = awful.titlebar.widget.titlewidget(c)
                    --font = 'Fira Code Nerd Font 25',
                    --markup = ' ',
                    --align = 'left',
                    widget = wibox.widget.textbox
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            --awful.titlebar.widget.floatingbutton (c),
            --awful.titlebar.widget.maximizedbutton(c),
            --awful.titlebar.widget.stickybutton   (c),
            --awful.titlebar.widget.ontopbutton    (c),
            wibox.layout.margin (
                awful.titlebar.widget.minimizebutton(c),
            8, 8, 8, 8),
            wibox.layout.margin (
                awful.titlebar.widget.closebutton(c),
            8, 8, 8, 8),
            layout = wibox.layout.flex.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Rounded corners
client.connect_signal("manage", function(c)
    c.shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, 10)
    end
end)








-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
--
--
--
