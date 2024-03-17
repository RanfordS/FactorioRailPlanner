---@enum Parity
local Parity =
{
    ex_ey = 0,
    ex_oy = 1,
    ox_ey = 2,
    ox_oy = 3,
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

return Parity
