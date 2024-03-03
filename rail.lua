local Vec = require "vec"
local Bezier = require "bezier"

---@type Vec[]
local directions = {
    [0] = Vec.new ( 2, 0),
    [1] = Vec.new ( 2,-1),
    [2] = Vec.new ( 1,-1),
    [3] = Vec.new ( 1,-2),
    [4] = Vec.new ( 0,-2),
    [5] = Vec.new (-1,-2),
    [6] = Vec.new (-1,-1),
    [7] = Vec.new (-2,-1),
}

---@class RailSegment
---@field a_pos Vec
---@field a_ang integer
---@field b_pos Vec
---@field b_ang integer
---@field path number[]
local RailSegment = {}
RailSegment.__index = RailSegment

---@param a_pos Vec
---@param a_ang integer
---@param b_pos Vec
---@param b_ang integer
local function new (a_pos, a_ang, b_pos, b_ang)
    return setmetatable (
    {   a_pos = a_pos,
        a_ang = a_ang,
        b_pos = b_pos,
        b_ang = b_ang,
    },  RailSegment)
end
RailSegment.new = new

--     5 4 3
--   6   |   2  
-- 7     |     1
-- 0 --- x --- 0
-- 1     |     7
--   2   |   6
--     3 4 5

function RailSegment:gen_path ()
    if self.a_ang == self.b_ang then
        self.path  = Vec.unwrap {self.a_pos, self.b_pos}
    else
        local a_dir = directions[self.a_ang]
        local b_dir = directions[self.b_ang]
        local lambda = Vec.cramer (0-a_dir, b_dir, self.a_pos - self.b_pos)
        local mid = self.a_pos + lambda.x*a_dir
        self.path = Vec.unwrap (Bezier.plot (self.a_pos, mid, self.b_pos, 8))
    end
    return self
end

function RailSegment:rotate_90 ()
    return new (self.a_pos:rotate_90 (), (self.a_ang + 12)%8, self.b_pos:rotate_90 (), (self.b_ang + 12)%8)
end

function RailSegment:mirror_x ()
    return new (self.a_pos:mirror_x (), (8 - self.a_ang)%8, self.b_pos:mirror_x (), (8 - self.a_ang)%8)
end

local curve_primatives = {
	new (Vec.new (0,0), 4, Vec.new (1,5), 5), -- curve start
	new (Vec.new (0,0), 5, Vec.new (3,4), 6), -- curve mid1
	new (Vec.new (0,0), 6, Vec.new (4,3), 7), -- curve mid2
	new (Vec.new (0,0), 7, Vec.new (5,1), 0), -- curve end
}
-- 4-types * 4-rotations = 16

local straight_primatives = {
	new (Vec.new (0,0), 4, Vec.new (0,2), 4), -- vertical
	new (Vec.new (0,0), 3, Vec.new (2,4), 3), -- 2:1
	new (Vec.new (0,0), 2, Vec.new (2,2), 2), -- 1:1
	new (Vec.new (0,0), 1, Vec.new (4,2), 1), -- 1:2
}
-- 4-types * 2-rotations =  8
RailSegment.basic = {}
for _, s in ipairs (curve_primatives) do
    local cur = s
    for i = 1, 4 do
        cur:gen_path ()
        table.insert (RailSegment.basic, cur)
        cur = cur:rotate_90 ()
    end
end
for _, s in ipairs (straight_primatives) do
    table.insert (RailSegment.basic, s:gen_path ())
    table.insert (RailSegment.basic, s:mirror_x ():gen_path ())
end

return RailSegment
