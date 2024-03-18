local Vec = require "vec"
local Bezier = {}

---@param p0 Vec
---@param p1 Vec
---@param p2 Vec
---@param r integer
---@return Vec[]
function Bezier.plot (p0, p1, p2, r)
    local a = p0
    local b = 2*(p1 - p0)
    local c = p2 - 2*p1 + p0

    local line = {}
    for i = 0, r do
        local t = i/r
        local v = a + b*t + c*t*t
        table.insert (line, v)
    end
    return line
end

---@param p0 Vec
---@param p1 Vec
---@param p2 Vec
---@param r integer
---@return Vec[]
function Bezier.tangent (p0, p1, p2, r)
    local b = 2*(p1 - p0)
    local c = 2*(p2 - 2*p1 + p0)

    local line = {}
    for i = 0, r do
        local t = i/r
        local v = b + c*t
        table.insert (line, v)
    end
    return line
end

return Bezier
