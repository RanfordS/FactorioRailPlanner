local Vec = require "vec"
local V = Vec.new

---@enum Parity
local Parity =
{
    eb = 0,
    ex = 1,
    ey = 2,
    ob = 3,
}

---@param v Vec
---@return Parity
function Parity.calc (v)
    local x = v.x % 2
    local y = v.y % 2
    return 2*y + x
end

---@param p Parity
---@return Parity
function Parity.rot (p)
    return ({0,2,1,3})[p+1]
end

---@type {[Parity]: Vec}
local offset = {
    [Parity.eb] = V(0,0),
    [Parity.ex] = V(0,1),
    [Parity.ey] = V(1,0),
    [Parity.ob] = V(1,1),
}

---@param v Vec
---@param p Parity
function Parity.closest (v, p)
    local off = offset[p]
    v = (v - off)/2
    v = v:round ()
    v = 2*v + off
    return v
end

return Parity
