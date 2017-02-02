
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2014, Luke Bonham                     
                                                  
--]]

local helpers      = require("lain.helpers")
local wibox        = require("wibox")
local setmetatable = setmetatable

-- Basic template for custom widgets
-- lain.widgets.base

local function worker(args)
    local base      = { widget = wibox.widget.textbox() }
    local args      = args or {}
    local timeout   = args.timeout or 5
    local nostart   = args.nostart or false
    local stoppable = args.stoppable or false
    local cmd       = args.cmd
    local settings  = args.settings or function() end

    function base.update()
        output = helpers.read_pipe(cmd)
        if output ~= base.prev then
            widget = base.widget
            settings()
            base.prev = output
        end
    end

    base.timer = helpers.newtimer(cmd, timeout, base.update, nostart, stoppable)

    return base
end

return setmetatable({}, { __call = function(_, ...) return worker(...) end })
