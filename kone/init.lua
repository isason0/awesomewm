-- Kone :
-- a simple and 'modal' dock for awesomewm
local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = require("beautiful.xresources").apply_dpi
local ff_imagebox
local tm_imagebox
local pn_imagebox
local ms_imagebox
local lk_imagebox
local kritarun = "krita"
local kpsxc = "keepassxc"
local cmusrun = "kitty cmus"
--local kritarun = "/home/tom/Applications/krita-4-4-5.appimage"

matchers = false

-- If you have png icons, do this for each box,
-- and also change containers :
-- (here I'm using nerd font icons as textboxes :D)
--ff_imagebox = wibox.widget {
    --image = "/home/tom/.config/awesome/icons/firefoxico.png",
    --widget = wibox.widget.imagebox,
--}

-- Icons {{{
-- Firefox Icon
ff_imagebox = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 35",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
-- Music Icon
ms_imagebox = wibox.widget {
    markup = "ﱘ",
    font = "Fira Code Nerd Font 35",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
-- Paint Icon
pn_imagebox = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 35",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
-- Terminal Icon
tm_imagebox = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 35",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
-- Keepassxc Icon
lk_imagebox = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 35",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}
-- Matcher mode indicator
mM_imagebox = wibox.widget {
    markup = "",
    font = "Fira Code Nerd Font 13",
    align = "center",
    valign = "center",
    visible = false,
    widget = wibox.widget.textbox,
}

--}}}

--{{{ Make dock functional

local tm_matcher = function(c)
    return awful.rules.match(c, {class = 'kitty'})
end
local ff_matcher = function(c)
    return awful.rules.match(c, {class = 'Firefox'})
end
local pn_matcher = function(c)
    return awful.rules.match(c, {class = 'krita'})
end
local lk_matcher = function(c)
    return awful.rules.match(c, {class = 'keepassxc'})
end

local tm_pressed = function(button)
    if matchers == true then
        awful.client.run_or_raise(terminal, tm_matcher)
    else
        awful.spawn(terminal)
    end
end
local ff_pressed = function(button)
    if matchers == true then
        awful.client.run_or_raise(browser, ff_matcher)
    else
        awful.spawn(browser)
    end
end
local pn_pressed = function(button)
    if matchers == true then
        awful.client.run_or_raise(kritarun, pn_matcher)
    else
        awful.spawn(kritarun)
    end
end
local lk_pressed = function(button)
    if matchers == true then
        awful.client.run_or_raise(kpsxc, lk_matcher)
    else
        awful.spawn(kpsxc)
    end
end
local ms_pressed = function(button)
        awful.spawn(cmusrun)
end

tm_imagebox:connect_signal("button::press", tm_pressed)
ff_imagebox:connect_signal("button::press", ff_pressed)
pn_imagebox:connect_signal("button::press", pn_pressed)
lk_imagebox:connect_signal("button::press", lk_pressed)
ms_imagebox:connect_signal("button::press", ms_pressed)
--}}}


-- Containers {{{

-- In case you have png icons, set up containers like this :
    --local ffcont = wibox.container.background(ff_imagebox)

local ffcont = wibox.widget{
    ff_imagebox,
    fg = "#ff79c6b3",
    widget = wibox.container.background
}
local mscont = wibox.widget{
    ms_imagebox,
    fg = "#bd93f9b3",
    widget = wibox.container.background
}
local pncont = wibox.widget{
    pn_imagebox,
    fg = "#8be9fdb3",
    widget = wibox.container.background
}
local tmcont = wibox.widget{
    tm_imagebox,
    fg = "#50fa7bb3",
    widget = wibox.container.background
}
local lkcont = wibox.widget{
    lk_imagebox,
    fg = "#ffb86cb3",
    widget = wibox.container.background
}
local mMfcont = wibox.widget{
    mM_imagebox,
    fg = "#ff79c6b3",
    widget = wibox.container.background
}
local mMtcont = wibox.widget{
    mM_imagebox,
    fg = "#50fa7bb3",
    widget = wibox.container.background
}
local mMscont = wibox.widget{
    mM_imagebox,
    fg = "#bd93f9b3",
    widget = wibox.container.background
}
local mMpcont = wibox.widget{
    mM_imagebox,
    fg = "#8be9fdb3",
    widget = wibox.container.background
}
local mMlcont = wibox.widget{
    mM_imagebox,
    fg = "#ffb86cb3",
    widget = wibox.container.background
}

-- Extra eye candy :
    -- If using images as icons, make sure to comment these out or change up functions.
tmcont:connect_signal("mouse::enter", function()
    tmcont.fg = "#50fa7b"
end)
tmcont:connect_signal("mouse::leave", function()
    tmcont.fg = "#50fa7bb3"
end)

ffcont:connect_signal("mouse::enter", function()
    ffcont.fg = "#ff79c6"
end)
ffcont:connect_signal("mouse::leave", function()
    ffcont.fg = "#ff79c6b3"
end)

mscont:connect_signal("mouse::enter", function()
    mscont.fg = "#bd93f9"
end)
mscont:connect_signal("mouse::leave", function()
    mscont.fg = "#bd93f9b3"
end)
pncont:connect_signal("mouse::enter", function()
    pncont.fg = "#8be9fd"
end)
pncont:connect_signal("mouse::leave", function()
    pncont.fg = "#8be9fdb3"
end)
lkcont:connect_signal("mouse::enter", function()
    lkcont.fg = "#ffb86c"
end)
lkcont:connect_signal("mouse::leave", function()
    lkcont.fg = "#ffb86cb3"
end)
--}}}

-- Final setup :
    -- Here you can change basic stuff like dock position,
    -- orientation, size and icon order.
konebox = wibox {
    ontop = true,
    -- x, y and width, height will be dependant on
    -- each other as well as resolution and oriention
    -- I am using 1080p with bottom horizontal dock
    x = 790,
    y = 1020,
    width = dpi(340),
    height = dpi(90),
    bg = "transparent",
    type = "dock",
    visible = true,
}
konebox:setup{
    {
        layout = wibox.layout.flex.horizontal, --(.vertical)
        -- icon order :
            {
                layout = wibox.layout.flex.vertical, --(.horizontal)
                ffcont,
                mMfcont,
            },
            {
                layout = wibox.layout.flex.vertical, --.-
                tmcont,
                mMtcont,
            },
            {
                layout = wibox.layout.flex.vertical, --.-
                mscont,
                mMscont,
            },
            {
                layout = wibox.layout.flex.vertical, --.-
                pncont,
                mMpcont,
            },
            {
                layout = wibox.layout.flex.vertical, --.-
                lkcont,
                mMlcont,
            },
    },
    widget = wibox.container.background,
}
