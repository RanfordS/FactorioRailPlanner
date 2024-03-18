---@class Vec
---@field x number
---@field y number
local Vec = {}
Vec.__index = Vec

---@param x number
---@param y number
---@return Vec
function Vec.new (x,y)
	return setmetatable ({x = x, y = y}, Vec)
end

function Vec.assure (a)
	local t = type (a)
	if t == "table"
	and getmetatable (a) == Vec then
		return a
	end
	if t == "number" then
		return Vec.new (a, a)
	end
	error ("Unhandled type "..t.." given to Vec.")
end

---@param lhs Vec
---@param rhs Vec
---@return Vec
function Vec.__add (lhs, rhs)
	lhs = Vec.assure (lhs)
	rhs = Vec.assure (rhs)
	return Vec.new (lhs.x + rhs.x, lhs.y + rhs.y)
end

---@param lhs Vec
---@param rhs Vec
---@return Vec
function Vec.__sub (lhs, rhs)
	lhs = Vec.assure (lhs)
	rhs = Vec.assure (rhs)
	return Vec.new (lhs.x - rhs.x, lhs.y - rhs.y)
end

---@param lhs Vec
---@param rhs Vec
---@return Vec
function Vec.__mul (lhs, rhs)
	lhs = Vec.assure (lhs)
	rhs = Vec.assure (rhs)
	return Vec.new (lhs.x * rhs.x, lhs.y * rhs.y)
end

---@param lhs Vec
---@param rhs Vec
---@return Vec
function Vec.__div (lhs, rhs)
	lhs = Vec.assure (lhs)
	rhs = Vec.assure (rhs)
	return Vec.new (lhs.x / rhs.x, lhs.y / rhs.y)
end

---@param val Vec
---@return Vec
function Vec.__unm (val)
    return Vec.new (-val.x, -val.y)
end

---@param val Vec
---@return number
function Vec.sum (val)
	return val.x + val.y
end

function Vec.round (val)
	return Vec.new (math.floor (val.x + 0.5), math.floor (val.y + 0.5))
end

function Vec.ceil (val)
	return Vec.new (math.ceil (val.x), math.ceil (val.y))
end

function Vec.floor (val)
	return Vec.new (math.floor (val.x), math.floor (val.y))
end

---@param lhs Vec
---@param rhs Vec
---@return number
function Vec.dot (lhs, rhs)
	return (lhs*rhs):sum ()
end

---@param val Vec
---@return number
function Vec.mag (val)
    return math.sqrt (val:dot(val))
end

---@param val Vec
---@return Vec
function Vec.norm (val)
    return val/val:mag()
end

---@param val Vec
---@return Vec
function Vec.rotate_90 (val)
	return Vec.new (-val.y, val.x)
end

---@param val Vec
---@return Vec
function Vec.mirror_x (val)
    return Vec.new (-val.x, val.y)
end

---@param lhs Vec
---@param rhs Vec
---@return number
function Vec.cross (lhs, rhs)
    return lhs.x*rhs.y - lhs.y*rhs.x
end

---@param a Vec Column 1 of the LHS matrix.
---@param b Vec Column 2 of the LHS matrix.
---@param c Vec The constants on the RHS.
---@return Vec
function Vec.cramer (a, b, c)
    local d = Vec.cross(a,b)
    local l = Vec.cross(c,b)
    local r = Vec.cross(a,c)
    return Vec.new (l/d, r/d)
end

---@param list Vec[]
---@return number[]
function Vec.unwrap (list)
    local array = {}
    for _, v in ipairs (list) do
        table.insert (array, v.x)
        table.insert (array, v.y)
    end
    return array
end

---@param a Vec
---@param b Vec
---@return Vec min
---@return Vec max
function Vec.bounds (a, b)
    local x_min = math.min (a.x, b.x)
    local x_max = math.max (a.x, b.x)
    local y_min = math.min (a.y, b.y)
    local y_max = math.max (a.y, b.y)
    return Vec.new (x_min, y_min), Vec.new (x_max, y_max)
end

return Vec
