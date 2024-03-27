-- This file contains the control scheme and user interactions for the "walk"
-- building mode. In this mode, the user selects the end of a rail and uses the
-- arrow key to build out.

require "rail-segment"

--- Get the "left", "straight", and "right" options that **connect** to the given angle.
---@param ang integer
---@return table
local function get_options (ang)
    return {
        l_seg = ("c%X"):format ((ang + 8) % 16),
        l_end = "a",
        s_seg = ("s%X"):format (ang % 8),
        s_end = ang < 8 and "b" or "a",
        r_seg = ("c%X"):format ((ang - 1) % 16),
        r_end = "b",
    }
end


