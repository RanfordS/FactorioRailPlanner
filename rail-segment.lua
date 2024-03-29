local Utils = require "Utils"
---@source love
local Vec = require "vec"
local V = Vec.new
local Bezier = require "bezier"
local Parity = require "parity"

---@class RailSegment
---@field pos_c Vec Center (for positioning).
---@field pos_a Vec
---@field pos_b Vec
---@field ang_a integer
---@field ang_b integer
---@field parity_a Parity
---@field parity_b Parity
---@field signal_a2b (Vec|false)[] These are the signals on the right as you travel from a to b.
---@field signal_b2a (Vec|false)[] These are the signals on the right as you travel from b to a, note that they are in reverse order as they pair with the elements of `signal_a2b`.
---@field geometry Vec[]
---@field path number[]
---@field top_left Vec
---@field bot_right Vec
local RailSegment = {}
RailSegment.__index = RailSegment

RailSegment.map_mirror_x = {
    c0 = "c7", c1 = "c6", c2 = "c5", c3 = "c4",
    c4 = "c3", c5 = "c2", c6 = "c1", c7 = "c0",
    c8 = "cF", c9 = "cE", cA = "cD", cB = "cC",
    cC = "cB", cD = "cA", cE = "c9", cF = "c8",
    s0 = "s0", s1 = "s7", s2 = "s6", s3 = "s5",
    s4 = "s4", s5 = "s3", s6 = "s2", s7 = "s1",
}

RailSegment.map_mirror_y = {
    c0 = "cF", c1 = "cE", c2 = "cD", c3 = "cC",
    c4 = "cB", c5 = "cA", c6 = "c9", c7 = "c8",
    c8 = "c7", c9 = "c6", cA = "c5", cB = "c4",
    cC = "c3", cD = "c2", cE = "c1", cF = "c0",
    s0 = "s0", s1 = "s7", s2 = "s6", s3 = "s5",
    s4 = "s4", s5 = "s3", s6 = "s2", s7 = "s1",
}

RailSegment.map_rotate_clock = {
    c0 = "cC", c1 = "cD", c2 = "cE", c3 = "cF",
    c4 = "c0", c5 = "c1", c6 = "c2", c7 = "c3",
    c8 = "c4", c9 = "c5", cA = "c6", cB = "c7",
    cC = "c8", cD = "c9", cE = "cA", cF = "cB",
    s0 = "s4", s1 = "s5", s2 = "s6", s3 = "s7",
    s4 = "s0", s5 = "s1", s6 = "s2", s7 = "s3",
}

RailSegment.map_rotate_anticlock = {
    c0 = "c4", c1 = "c5", c2 = "c6", c3 = "c7",
    c4 = "c8", c5 = "c9", c6 = "cA", c7 = "cB",
    c8 = "cC", c9 = "cD", cA = "cE", cB = "cF",
    cC = "c0", cD = "c1", cE = "c2", cF = "c3",
    s0 = "s4", s1 = "s5", s2 = "s6", s3 = "s7",
    s4 = "s0", s5 = "s1", s6 = "s2", s7 = "s3",
}

---@param pos_a Vec
---@param aa integer
---@param ap Parity
---@param asig (Vec|false)[]
---@param pos_b Vec
---@param ba integer
---@param bp Parity
---@param bsig (Vec|false)[]
---@return RailSegment
function RailSegment.new (pos_a, aa, ap, asig, pos_b, ba, bp, bsig)
    return setmetatable (
    {   pos_a = pos_a,
        pos_b = pos_b,
        ang_a = aa,
        ang_b = ba,
        parity_a = ap,
        parity_b = bp,
        signal_a2b = asig,
        signal_b2a = bsig,
        pos_c = (pos_a + pos_b)/2,
    },  RailSegment):gen_path ()
end
local new = RailSegment.new

--     5 4 3
--   6   |   2
-- 7     |     1   -
-- 8 --- x --- 0   y
-- 9     |     F   +
--   A   |   E
--     B C D
--
--     - x +

local directions = {
    [ 0] = V( 2, 0),
    [ 1] = V( 2,-1),
    [ 2] = V( 1,-1),
    [ 3] = V( 1,-2),
    [ 4] = V( 0,-2),
    [ 5] = V(-1,-2),
    [ 6] = V(-1,-1),
    [ 7] = V(-2,-1),
    [ 8] = V(-2, 0),
    [ 9] = V(-2, 1),
    [10] = V(-1, 1),
    [11] = V(-1, 2),
    [12] = V( 0, 2),
    [13] = V( 1, 2),
    [14] = V( 1, 1),
    [15] = V( 2, 1),
}



---@return RailSegment
function RailSegment:gen_path ()
    local radius = 0.6
    ---@type Vec[]
    local tangents
    ---@type Vec[]
    local positions
    if (self.ang_a % 8) == (self.ang_b % 8) then
        positions = {self.pos_a, self.pos_b}
        tangents = {0-directions[self.ang_a]:norm (), directions[self.ang_b]:norm ()}
    else
        local dir_a = directions[self.ang_a]
        local dir_b = directions[self.ang_b]
        local lambda = Vec.cramer (0-dir_a, dir_b, self.pos_a - self.pos_b)
        local mid = self.pos_a + lambda.x*dir_a
        positions = Bezier.plot (self.pos_a, mid, self.pos_b, 8)
        tangents = Bezier.tangent (self.pos_a, mid, self.pos_b, 8)
        tangents = Utils.array_func (tangents, Vec.norm)
    end
    ---@type Vec[]
    local points = {}
    self.top_left = Vec.new (math.huge, math.huge)
    self.bot_right = 0-self.top_left
    for i, p in ipairs (positions) do
        local n = tangents[i]:rotate_90 ()*radius
        local lhs = p - n
        local rhs = p + n
        self.top_left.x  = math.min (self.top_left.x,  lhs.x, rhs.x)
        self.top_left.y  = math.min (self.top_left.y,  lhs.y, rhs.y)
        self.bot_right.x = math.max (self.bot_right.x, lhs.x, rhs.x)
        self.bot_right.y = math.max (self.bot_right.y, lhs.y, rhs.y)
        table.insert (points,    lhs)
        table.insert (points, 1, rhs)
    end
    self.geometry = points
    self.path = Vec.unwrap (points)
    return self
end

function RailSegment:contains (p)
    -- bounding box shortcut
    if p.x < self.top_left.x
    or p.y < self.top_left.y
    or p.x > self.bot_right.x
    or p.y > self.bot_right.y
    then return false end
    -- hacky sidedness algorithm begins,
    -- find the closes edge point to `p`
    local b_dist = math.huge
    local b_i = 1
    for i, v in ipairs (self.geometry) do
        local dist = (v - p):mag ()
        if dist < b_dist then
            b_dist = dist
            b_i = i
        end
    end
    -- get the neighbouring points
    local a_i = ((b_i - 2) % #self.geometry) + 1
    local c_i = (b_i % #self.geometry) + 1
    -- some definitions
    local a = self.geometry[a_i]
    local b = self.geometry[b_i]
    local c = self.geometry[c_i]
    local ba = a - b
    local bc = c - b
    local bp = p - b
    -- determine if it's a concave or convex edge
    local ang = ba:cross(bc)
    -- edge sidedness values
    local alpha = bp:cross(ba)
    local kappa  = bc:cross(bp)
    if ang < 0 then
        return alpha > 0 and kappa > 0
    else
        return alpha > 0 or  kappa > 0
    end
end



-- Curves

RailSegment.c0 = RailSegment.new (
    V(5,2),  0, Parity.ex, {V(4.5,0.5), V(0.5,1.5)},
    V(0,3),  9, Parity.ey, {V(4.5,3.5), V(1.5,3.5)})

RailSegment.c1 = RailSegment.new (
    V(5,1),  1, Parity.ey, {V(3.5,0.5), V(2.5,1.5), V(0.5,2.5)},
    V(1,4), 10, Parity.ob, {V(4.5,2.5),    false,   V(2.5,4.5)})

RailSegment.c2 = RailSegment.new (
    V(4,1),  2, Parity.ob, {V(2.5,0.5), V(1.5,2.5), V(0.5,3.5)},
    V(1,5), 11, Parity.ex, {V(4.5,2.5),    false,   V(2.5,4.5)})

RailSegment.c3 = RailSegment.new (
    V(3,0),  3, Parity.ex, {V(1.5,0.5), V(0.5,4.5)},
    V(2,5), 12, Parity.ey, {V(3.5,1.5), V(3.5,4.5)})

RailSegment.c4 = RailSegment.new (
    V(2,0),  4, Parity.ey, {V(0.5,0.5), V(1.5,4.5)},
    V(3,5), 13, Parity.ex, {V(3.5,0.5), V(3.5,3.5)})

RailSegment.c5 = RailSegment.new (
    V(1,0),  5, Parity.ex, {V(0.5,1.5), V(1.5,2.5), V(2.5,4.5)},
    V(4,4), 14, Parity.ob, {V(2.5,0.5),    false,   V(4.5,2.5)})

RailSegment.c6 = RailSegment.new (
    V(1,1),  6, Parity.ob, {V(0.5,2.5), V(2.5,3.5), V(3.5,4.5)},
    V(5,4), 15, Parity.ey, {V(2.5,0.5),    false,   V(4.5,2.5)})

RailSegment.c7 = RailSegment.new (
    V(0,1),  7, Parity.ey, {V(0.5,2.5), V(4.5,3.5)},
    V(5,2),  0, Parity.ex, {V(1.5,0.5), V(4.5,0.5)})

RailSegment.c8 = RailSegment.new (
    V(0,2),  8, Parity.ex, {V(0.5,3.5), V(4.5,2.5)},
    V(5,1),  1, Parity.ey, {V(0.5,0.5), V(3.5,0.5)})

RailSegment.c9 = RailSegment.new (
    V(0,4),  9, Parity.ey, {V(1.5,4.5), V(2.5,3.5), V(4.5,2.5)},
    V(4,1),  2, Parity.ob, {V(0.5,2.5),    false,   V(2.5,0.5)})

RailSegment.cA = RailSegment.new (
    V(1,4), 10, Parity.ob, {V(2.5,4.5), V(3.5,2.5), V(4.5,1.5)},
    V(4,0),  3, Parity.ex, {V(0.5,2.5),    false,   V(2.5,0.5)})

RailSegment.cB = RailSegment.new (
    V(1,5), 11, Parity.ex, {V(2.5,4.5), V(3.5,0.5)},
    V(2,0),  4, Parity.ey, {V(0.5,3.5), V(0.5,0.5)})

RailSegment.cC = RailSegment.new (
    V(2,5), 12, Parity.ey, {V(3.5,4.5), V(2.5,0.5)},
    V(1,0),  5, Parity.ex, {V(0.5,4.5), V(0.5,1.5)})

RailSegment.cD = RailSegment.new (
    V(4,5), 13, Parity.ex, {V(4.5,3.5), V(3.5,2.5), V(2.5,0.5)},
    V(1,1),  6, Parity.ob, {V(2.5,4.5),    false,   V(0.5,2.5)})

RailSegment.cE = RailSegment.new (
    V(4,4), 14, Parity.ob, {V(4.5,2.5), V(2.5,1.5), V(1.5,0.5)},
    V(0,1),  7, Parity.ey, {V(2.5,4.5),    false,   V(0.5,2.5)})

RailSegment.cF = RailSegment.new (
    V(5,3), 15, Parity.ey, {V(4.5,1.5), V(0.5,0.5)},
    V(0,2),  8, Parity.ex, {V(3.5,3.5), V(0.5,3.5)})

-- Straights

RailSegment.s0 = RailSegment.new (
    V(2,2),  0, Parity.ex, {V(1.5,0.5), V(0.5,0.5)},
    V(0,2),  8, Parity.ex, {V(1.5,3.5), V(0.5,3.5)})

RailSegment.s1 = RailSegment.new (
    V(4,1),  1, Parity.ey, {V(2.5,0.5), V(0.5,1.5)},
    V(0,3),  9, Parity.ey, {V(3.5,2.5), V(1.5,3.5)})

RailSegment.s2 = RailSegment.new (
    V(3,1),  2, Parity.ob, {V(1.5,0.5), V(0.5,1.5)},
    V(1,3), 10, Parity.ob, {V(3.5,2.5), V(2.5,3.5)})

RailSegment.s3 = RailSegment.new (
    V(3,0),  3, Parity.ex, {V(1.5,0.5), V(0.5,2.5)},
    V(1,4), 11, Parity.ex, {V(3.5,1.5), V(2.5,3.5)})

RailSegment.s4 = RailSegment.new (
    V(2,0),  4, Parity.ey, {V(0.5,0.5), V(0.5,1.5)},
    V(2,2), 12, Parity.ey, {V(3.5,0.5), V(3.5,1.5)})

RailSegment.s5 = RailSegment.new (
    V(1,0),  5, Parity.ex, {V(0.5,1.5), V(1.5,3.5)},
    V(3,4), 13, Parity.ex, {V(2.5,0.5), V(3.5,2.5)})

RailSegment.s6 = RailSegment.new (
    V(1,1),  6, Parity.ob, {V(0.5,2.5), V(1.5,3.5)},
    V(3,3), 14, Parity.ob, {V(2.5,0.5), V(3.5,1.5)})

RailSegment.s7 = RailSegment.new (
    V(0,1),  7, Parity.ey, {V(0.5,2.5), V(2.5,3.5)},
    V(4,3), 15, Parity.ey, {V(1.5,0.5), V(3.5,1.5)})

return RailSegment
