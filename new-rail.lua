local Utils = require "Utils"
---@source love
local Vec = require "vec"
local V = Vec.new
local Bezier = require "bezier"

---@class RailSegment
---@field pos_a Vec
---@field pos_b Vec
---@field ang_a integer
---@field ang_b integer
---@field parity_a GridParity
---@field parity_b GridParity
---@field signal_a (Vec|false)[] These are the signals on the left as you go from A to B.
---@field signal_b (Vec|false)[] These are the signals opposite those in signal_a.
---@field path number[]
local RailSegment = {}
RailSegment.__index = RailSegment

local map_mirror_x =
{
    c0 = "c7", c1 = "c6", c2 = "c5", c3 = "c4",
    c4 = "c3", c5 = "c2", c6 = "c1", c7 = "c0",
    c8 = "cF", c9 = "cE", cA = "cD", cB = "cC",
    cC = "cB", cD = "cA", cE = "c9", cF = "c8",
    s0 = "s0", s1 = "s7", s2 = "s6", s3 = "s5",
    s4 = "s4", s5 = "s3", s6 = "s2", s7 = "s1",
}

local map_mirror_y =
{
    c0 = "cF", c1 = "cE", c2 = "cD", c3 = "cC",
    c4 = "cB", c5 = "cA", c6 = "c9", c7 = "c8",
    c8 = "c7", c9 = "c6", cA = "c5", cB = "c4",
    cC = "c3", cD = "c2", cE = "c1", cF = "c0",
    s0 = "s0", s1 = "s7", s2 = "s6", s3 = "s5",
    s4 = "s4", s5 = "s3", s6 = "s2", s7 = "s1",
}

local map_rotate

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

---@param pos_a Vec
---@param ay integer
---@param aa integer
---@param ap GridParity
---@param pos_b Vec
---@param ba integer
---@param bp GridParity
---@return RailSegment
function RailSegment.new (pos_a, aa, ap, pos_b, ba, bp, asig, bsig)
    return setmetatable (
    {   pos_a = pos_a,
        pos_b = pos_b,
        ang_a = aa,
        ang_b = ba,
        parity_a = ap,
        parity_b = bp,
        signal_a = asig,
        signal_b = bsig,
    },  RailSegment):gen_path ()
end
local new = RailSegment.new

--     5 4 3
--   6   |   2  
-- 7     |     1
-- 0 --- x --- 0
-- 1     |     7
--   2   |   6
--     3 4 5

local directions = {
    [0] = V( 2, 0),
    [1] = V( 2,-1),
    [2] = V( 1,-1),
    [3] = V( 1,-2),
    [4] = V( 0, 2),
    [5] = V( 1, 2),
    [6] = V( 1, 1),
    [7] = V( 2, 1),
}

local function mirror_dir (i)
    return (8 - i)%8
end

local function rot_dir (i)
    return (i + 4)%8
end

---@param arr (Vec|false)[]
---@return (Vec|false)[]
local function mirror_signal (arr)
    local res = {}
    for i, v in ipairs (arr) do
        if v == false then
            res[i] = v
        else
            res[i] = v:mirror_x ()
        end
    end
    return res
end



---@return RailSegment
function RailSegment:gen_path ()
    if self.ang_a == self.ang_b then
        self.path = {self.pos_a.x, self.pos_a.y, self.pos_b.x, self.pos_b.y}
    else
        local dir_a = directions[self.ang_a]
        local dir_b = directions[self.ang_b]
        local lambda = Vec.cramer (0-dir_a, dir_b, self.pos_a - self.pos_b)
        local mid = self.pos_a + lambda.x*dir_a
        local points = Bezier.plot (self.pos_a, mid, self.pos_b, 8)
        self.path = Vec.unwrap (points)
    end
    return self
end

function RailSegment:rot ()
    return new (
        self.pos_a:rotate_90 (), rot_dir (self.ang_a), rot_parity (self.parity_a),
        self.pos_b:rotate_90 (), rot_dir (self.ang_b), rot_parity (self.parity_b),
        Utils.array_func (self.signal_a, Vec.rotate_90),
        Utils.array_func (self.signal_b, Vec.rotate_90))
end

--[[ not needed
function RailSegment:mirror ()
    return new (
        self.pos_a:mirror_x (), mirror_dir (self.ang_a), self.parity_a,
        self.pos_b:mirror_x (), mirror_dir (self.ang_b), self.parity_b,
        Utils.array_func (self.signal_b, Vec.mirror_x),
        Utils.array_func (self.signal_a, Vec.mirror_x))
end
--]]

local a3 = RailSegment.new (
    V(0,0), 0, GridParity.ox_ey,
    V(5,1), 7, GridParity.ex_oy,
    {},
    {})

local a2 = RailSegment.new (
    V(0,0), 7, GridParity.ox_ey,
    V(4,3), 6, GridParity.ex_oy)

local a1 = RailSegment.new (
    V(0,0), 6, GridParity.ox_ey,
    V(3,4), 5, GridParity.ex_oy)

local a0 = RailSegment.new (
    V(0,0), 5, GridParity.ox_ey,
    V(1,5), 4, GridParity.ex_oy)

local s0 = RailSegment.new (
    V(0,0), 0, GridParity.ex_oy,
    V(2,0), 0, GridParity.ex_oy)

local s1 = RailSegment.new (
    V(0,2), 1, GridParity.ox_ey,
    V(4,0), 1, GridParity.ox_ey)

local s2 = RailSegment.new (
    V(0,2), 2, GridParity.ox_oy,
    V(2,0), 2, GridParity.ox_oy)

local s3 = RailSegment.new (
    V(0,4), 3, GridParity.ex_oy,
    V(2,0), 3, GridParity.ex_oy)

RailSegment.curve = {}
for i, s in ipairs {a0, a1, a2, a3} do
    RailSegment.curve[i-1] = s
    local seg = s
    for j = 1, 3 do
        seg = seg:rot ()
        RailSegment.curve[i + 4*j - 1] = seg
    end
end

RailSegment.straight = {}
for i, s in ipairs {s0, s1, s2, s3} do
    RailSegment.curve[i-1] = s
    RailSegment.curve[i+3] = s:rot ()
end

return RailSegment
