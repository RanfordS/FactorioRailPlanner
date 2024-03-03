---@source love
local Vec = require "vec"
local Bezier = require "bezier"

---@class RailTemplate
---@field pos_a Vec
---@field pos_b Vec
---@field ang_a integer
---@field ang_b integer
---@field parity_a GridParity
---@field parity_b GridParity
---@field path number[]
local RailTemplate = {}
RailTemplate.__index = RailTemplate


local function calc_parity (v)
    local x = v.x % 2
    local y = v.y % 2
    return 2*y + x
end

---@enum GridParity
local GridParity =
{
    ex_ey = 0,
    ex_oy = 1,
    ox_ey = 2,
    ox_oy = 3,
}

---@param p GridParity
---@return GridParity
local function rot_parity (p)
    return ({0,2,1,3})[p+1]
end

---@param ax integer
---@param ay integer
---@param aa integer
---@param ap GridParity
---@param bx integer
---@param by integer
---@param ba integer
---@param bp GridParity
---@return RailTemplate
function RailTemplate.new (ax, ay, aa, ap, bx, by, ba, bp)
    return setmetatable (
    {   pos_a = Vec.new (ax, ay),
        pos_b = Vec.new (bx, by),
        ang_a = aa,
        ang_b = ba,
        parity_a = ap,
        parity_b = bp,
    },  RailTemplate):gen_path ()
end
local new = RailTemplate.new

--     5 4 3
--   6   |   2  
-- 7     |     1
-- 0 --- x --- 0
-- 1     |     7
--   2   |   6
--     3 4 5

local directions = {
    [0] = Vec.new ( 2, 0),
    [1] = Vec.new ( 2,-1),
    [2] = Vec.new ( 1,-1),
    [3] = Vec.new ( 1,-2),
    [4] = Vec.new ( 0, 2),
    [5] = Vec.new ( 1, 2),
    [6] = Vec.new ( 1, 1),
    [7] = Vec.new ( 2, 1),
}

local function mirror_dir (i)
    return (8 - i)%8
end

local function rot_dir (i)
    return (i + 4)%8
end



---@return RailTemplate
function RailTemplate:gen_path ()
    if self.ang_a == self.ang_b then
        self.path = {self.pos_a.x, self.pos_a.y, self.pos_b.x, self.pos_b.y}
    else
        local dir_a = directions[self.ang_a]
        local dir_b = directions[self.ang_b]
        local lambda = Vec.cramer (0-dir_a, dir_b, self.pos_a - self.pos_b)
        local mid = self.pos_a + lambda.x*dir_a
        local points = Bezier.plot (self.pos_a, mid, self.pos_b)
        self.path = Vec.unwrap (points)
    end
    return self
end

function RailTemplate:rot ()
    return new (
         self.pos_a.y,
        -self.pos_a.x,
        rot_dir (self.ang_a),
        rot_parity (self.parity_a),
         self.pos_b.y,
        -self.pos_b.x,
        rot_dir (self.ang_b),
        rot_parity (self.parity_b))
end

function RailTemplate:mirror ()
    return new (
        -self.pos_a.x,
         self.pos_a.y,
        mirror_dir (self.ang_a),
        self.parity_a,
        -self.pos_b.x,
         self.pos_b.y,
        mirror_dir (self.ang_b),
        self.parity_b)
end

local a3 = RailTemplate.new (
    0,0, 0, GridParity.ox_ey,
    5,1, 7, GridParity.ex_oy)

local a2 = RailTemplate.new (
    0,0, 7, GridParity.ox_ey,
    4,3, 6, GridParity.ex_oy)

local a1 = RailTemplate.new (
    0,0, 6, GridParity.ox_ey,
    3,4, 5, GridParity.ex_oy)

local a0 = RailTemplate.new (
    0,0, 5, GridParity.ox_ey,
    1,5, 4, GridParity.ex_oy)

local s0 = RailTemplate.new (
    0,0, 0, GridParity.ex_oy,
    2,0, 0, GridParity.ex_oy)

local s1 = RailTemplate.new (
    0,2, 1, GridParity.ox_ey,
    4,0, 1, GridParity.ox_ey)

local s2 = RailTemplate.new (
    0,2, 2, GridParity.ox_oy,
    2,0, 2, GridParity.ox_oy)

local s3 = RailTemplate.new (
    0,4, 3, GridParity.ex_oy,
    2,0, 3, GridParity.ex_oy)

return RailTemplate
