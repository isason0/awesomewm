-- My spin of a pretty basic awesomewm sidebar / stat bar
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local Value
local brTest
local vmTest
local br_ico
local pw_ico
--local vm_ico
local sdn_ico
local slp_ico
local lgo_ico
local mytagbox
local mylayoutbox
local notik_myclock
local notik_mydate
local notik_mysystray

-- Shell command that checks battery state
local pwcmd = [[
    sh -c "
    cat /sys/class/power_supply/BAT0/capacity
    "]]
-- -:- brightness cmd
local brcmd = [[
    sh -c "
    /usr/bin/xbacklight -get
    "]]
-- -:- volume cmd
local vmcmd = [[
    sh -c "
    /usr/bin/pulsemixer --get-volume | awk '{print $1}'
    "]]
-- -:- mute cmd
local mutecmd = [[
    sh -c "
    /usr/bin/pulsemixer --get-mute
    "]]

-- Progressbars for brightness, battery state and volume
-- {{{
local pw_progressbar = wibox.widget {
    max_value = 100,
    forced_height = 20,
    forced_width = 100,
    shape = gears.shape.rounded_bar,
    color = "#ff79c6",
    background_color = "#ff79c666",
    widget = wibox.widget.progressbar
}
br_progressbar = wibox.widget {
    max_value = 100,
    forced_height = 20,
    forced_width = 100,
    shape = gears.shape.rounded_bar,
    color = "#bd93f9",
    background_color = "#bd93f966",
    widget = wibox.widget.progressbar
}
vm_progressbar = wibox.widget {
    max_value = 100,
    forced_height = 20,
    forced_width = 100,
    shape = gears.shape.rounded_bar,
    color = "#50fa7b",
    background_color = "#50fa7b66",
    widget = wibox.widget.progressbar
}
--}}}

-- Text indicators for brightness and battery state
-- {{{
br_tex = wibox.widget {
    markup = "na",
    font = "Fira Code Nerd Font 20",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
pw_tex = wibox.widget {
    markup = "30",
    font = "Fira Code Nerd Font 20",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
vm_tex = wibox.widget {
    markup = "30",
    font = "Fira Code Nerd Font 20",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
--}}}

-- Timers : {{{
-- Get battery state every n seconds
gears.timer {
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = function()
        awful.spawn.with_line_callback(pwcmd, {
        stdout = function(line)
            pw_tex.markup = line
            Value = tonumber(line)
            pw_progressbar.value = Value
        end
    })
    end
}

-- Adjust brightness every 8 seconds, because
-- awesomewm is a single threaded fuck and acpilight lags
gears.timer {
    timeout = 8,
    call_now = true,
    autostart = true,
    callback = function()
        awful.spawn.with_line_callback(brcmd, {
            stdout = function(line)
                br_tex.markup = line
                brTest = tonumber(line)
                br_progressbar.value = brTest
            end
        })
    end
}
-- Same thing for volume but every 30 seconds.
gears.timer {
    timeout = 30,
    call_now = true,
    autostart = true,
    callback = function()
        awful.spawn.with_line_callback(vmcmd, {
            stdout = function(line)
                vm_tex.markup = line
                vmTest = tonumber(line)
                vm_progressbar.value = vmTest
            end
        })
    end
}

--}}}

-- Icons for brightness, battery and volume
-- {{{
br_ico = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 30",
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
}
pw_ico = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 26",
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
}
vm_ico = wibox.widget {
    --markup = "墳",
    font = "Fira Code Nerd Font 30",
    align = "left",
    valign = "center",
    widget = wibox.widget.textbox
}
-- Initialize volume icon
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

slp_ico = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 25",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
sdn_ico = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 25",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
lgo_ico = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 25",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
lgo_ico:connect_signal("button::press", function()
    awful.spawn.with_shell("sleep 0.4; xset dpms force off")
end)
slp_ico:connect_signal("button::press", function()
    awful.spawn.with_shell("loginctl suspend")
end)
-- !! super specific to my system :
sdn_ico:connect_signal("button::press", function()
    awful.spawn("loginctl hibernate")
end)

--}}}

-- Tags & layouts : {{{
-- make a tagbox
mytagbox = wibox.widget {
    font = "Fira Code Nerd Font 30",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}
-- make tagbox clickable :
mytagbox:connect_signal("button::press", function()
    awful.tag.viewnext(1)
end)
-- update tagbox when changing tags
screen[1]:connect_signal("tag::history::update", function()
    mytagbox.markup = awful.tag.selected(1).name
end)
-- make a layoutbox
mylayoutbox = awful.widget.layoutbox(1)
-- Systray :
notik_mysystray = wibox.widget {
    forced_height = 25,
    forced_width = 25,
    widget = wibox.widget.systray()
}
--}}}

-- Clock : {{{

notik_myclock = wibox.widget.textclock(
    '<span color="#f8f8f2"font="FiraCodeNerdFont 32">%H:%M %p</span>'
    ,15)
    --<span> is formatting (color and font)
    --%l is hours in a 12-hour format (%H would be 24-hour)
    --%M is minutes
    --%p gives am or pm
    --</span> closes formatting
    --15 is refresh rate in seconds

-- Date :
notik_mydate = wibox.widget.textclock(
    '<span color="#f8f8f2"font="FiraCodeNerdFont 15">%a %b %d</span>'
    ,60)
--}}}


-- Containers {{{

-- brightness
local br_cont = wibox.widget {
    br_tex,
    fg = "#bd93f966",
    widget = wibox.container.background
}
local br_contIco = wibox.widget {
    br_ico,
    fg = "#bd93f9",
    widget = wibox.container.background
}
-- power
local pw_cont = wibox.widget {
    pw_tex,
    fg = "#ff79c666",
    widget = wibox.container.background
}
local pw_contIco = wibox.widget {
    pw_ico,
    fg = "#ff79c6",
    widget = wibox.container.background
}
-- volume
local vm_cont = wibox.widget{
    vm_tex,
    fg = "#50fa7b66",
    widget = wibox.container.background
}
local vm_contIco = wibox.widget {
    vm_ico,
    fg = "#50fa7b",
    widget = wibox.container.background
}

-- exit features
local slp_cont = wibox.widget{
    slp_ico,
    fg = "#8be9fd",
    widget = wibox.container.background
}
local sdn_cont = wibox.widget{
    sdn_ico,
    fg = "#ff79c6",
    widget = wibox.container.background
}
local lgo_cont = wibox.widget{
    lgo_ico,
    fg = "#bd93f9",
    widget = wibox.container.background
}

-- Progressbars :
local progress_cont = wibox.container.place(pw_progressbar) --power
local progress_cont2 = wibox.container.place(br_progressbar) --brightness
local progress_cont3 = wibox.container.place(vm_progressbar) --volume

-- Tagbox :
local t_cont = wibox.widget{
    mytagbox,
    fg = "#f8f8f2",
    widget = wibox.container.background
}
-- Layoutbox :
local l_cont = wibox.widget{
    mylayoutbox,
    forced_height = 32,
    forced_width = 30,
    widget = wibox.container.place
}
-- systray :
--tray_cont = wibox.container.place(notik_mysystray)
tray_cont = wibox.widget {
    wibox.layout.margin(
    notik_mysystray,
    44, 0, 0, 0),
    valign = "center",
    halign = "left",
    widget = wibox.container.place
}
-- textclock :
local clock_cont = wibox.widget {
    wibox.layout.margin (
        notik_myclock,
    0, 10, 0, 0),
    valign = "center",
    halign = "center",
    widget = wibox.container.place
}
-- date :
local date_cont = wibox.widget {
    notik_mydate,
    valign = "center",
    halign = "center",
    widget = wibox.container.place
}


-- Group individual widgets together, making final setup easier :
    -- !!tip layout.margin - Margin orders: (left, right, top, bottom) !!
-- brightness :
local brC = wibox.widget {
    --text
    wibox.layout.margin(
        br_cont,
    20, 0, 0, 0),
    wibox.layout.margin(
    --icon
        br_contIco,
    10, 0, 0, 0),
    --progressbar
    wibox.layout.margin(
        progress_cont2,
    0, 25, 0, 0),
    layout = wibox.layout.align.horizontal
}
-- power :
local pwC = wibox.widget {
    --text
    wibox.layout.margin(
        pw_cont,
    20, 0, 0, 0),
    wibox.layout.margin(
    --icon
        pw_contIco,
    10, 0, 0, 0),
    wibox.layout.margin(
    --progressbar
        progress_cont,
    0, 25, 0, 0),
    layout = wibox.layout.align.horizontal
}
-- volume :
local vmC = wibox.widget {
    --text
    wibox.layout.margin(
        vm_cont,
    20, 0, 0, 0),
    --icon
    wibox.layout.margin(
        vm_contIco,
    10, 0, 0, 0),
    --progressbar
    wibox.layout.margin(
        progress_cont3,
    0, 25, 0, 0),
    layout = wibox.layout.align.horizontal
}
-- tags :
local tagC = wibox.widget {
    --layoutbox
    wibox.layout.margin(
    l_cont,
    65, 0, 0, 0),
    --tagbox
    wibox.layout.margin(
    t_cont,
    0, 70, 0, 0),
    layout = wibox.layout.align.horizontal
}
-- clock stuff :
local clockC = wibox.widget {
    --textclock
    wibox.layout.margin(
    clock_cont,
    0, 0, 80, 0),
    --date
    wibox.layout.margin(
    date_cont,
    0, 0, 10, 0),
    layout = wibox.layout.fixed.vertical
}
-- exit features :
local exitC = wibox.widget {
    wibox.layout.margin(
    lgo_cont,
    30, 0, 0, 0),
    slp_cont,
    wibox.layout.margin(
    sdn_cont,
    0, 30, 0, 0),
    layout = wibox.layout.flex.horizontal
}
--}}}


-- Initialize the background box :
    -- Here you can change basic stuff like box size,
    -- shape, dimensions and background color.
notikbox = wibox {
    ontop = true,
    x = 0,
    --y = 30,
    y = 75,
    width = dpi(250),
    --height = dpi(955),
    height = dpi(885),
    shape = function(cr,w ,h)
        gears.shape.partially_rounded_rect(cr, w, h,
        false, true, true, false)
    end,
    bg = "#1d1e26",
}

-- Init widgets :
    -- Here you can change the order of widgets
notikbox:setup{
    {
        layout = wibox.layout.flex.vertical,
        clockC, --clock
        tagC, --tags
        {
            layout = wibox.layout.fixed.vertical,
            pwC, --power stats
            brC, --brightness stats
            vmC, --volume stats
        },
        {
        layout = wibox.layout.align.vertical,
        wibox.layout.margin(
        exitC, --exit stuff
        0, 0, 80, 0),
        tray_cont, --systray
        },
    },
    widget = wibox.container.background,
}
