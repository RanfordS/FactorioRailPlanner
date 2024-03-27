local Parity = require "parity"

local positioning = {}

---@param pos Vec The point you want to transform (usually the mouse world position).
---@param ref Vec A reference marker (usually the relative centre of the object).
---@param anchor Vec An anchor point.
---@param anchor_parity Parity The parity of the anchor point.
function positioning.snap (pos, ref, anchor, anchor_parity)
    local relative = pos + anchor - ref
    local snapped = Parity.closest (relative, anchor_parity)
    return snapped - anchor
end

return positioning
