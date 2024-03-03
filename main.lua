---@source love
local Vec = require "vec"
local Rail = require "rail"


-- Factorio's coordinates are as follows, everything developed to match
-- 	#--> x
-- 	|
-- 	V
-- 	y

-- Horizontal rails are given an angle index of 0, and the index increases as we proceed clockwise

Debug_info = {}
function Debug (str, ...)
    table.insert (Debug_info, tostring (str):format (...))
end

local bg_dark  = {27/255, 27/255, 27/255}
local bg_light = {48/255, 48/255, 48/255}
local fg_cursor = {1.0, 0.5, 0.2}

local cam = {
	pos = Vec.new (0,0),
	zoom = 1,
	scale = 1,
	base_speed = 200,
	shift_speed = 500,
}
function cam.set_zoom (z)
	cam.zoom = z
	cam.scale = 2^(z/2)
end
cam.set_zoom (8)

local function screen_to_world (win, pos)
	return (pos - win/2)/cam.scale + cam.pos
end

function love.load ()
	love.graphics.setBackgroundColor (bg_dark)
end

function love.wheelmoved (x, y)
	if 0 < y then
		cam.set_zoom (cam.zoom + 1)
	elseif y < 0 then
		cam.set_zoom (math.max (cam.zoom - 1, 0))
	end
end

local cam_movement = {
	w = Vec.new ( 0,-1),
	s = Vec.new ( 0, 1),
	a = Vec.new (-1, 0),
	d = Vec.new ( 1, 0),
}

function love.update (dt)
	local speed = love.keyboard.isDown "lshift" and cam.shift_speed or cam.base_speed
	speed = speed/cam.scale
	for k, v in pairs (cam_movement) do
		if love.keyboard.isDown (k) then
			cam.pos = cam.pos + v*dt*speed
		end
	end
end

local function checkers (win)
	local tl = screen_to_world (win, Vec.new (0,0)):floor ()
	local br = screen_to_world (win, win):ceil ()

	local dbg_off = 0

	for r = tl.y+dbg_off, br.y-1-dbg_off do
		for c = tl.x+dbg_off, br.x-1-dbg_off do
			if (r + c) % 2 == 0 then
				love.graphics.rectangle ("fill", c, r, 1, 1)
			end
		end
	end
end

local idx = 1
function love.mousepressed (x, y, button, istouch, presses)
    idx = (idx % #Rail.basic) + 1
end

---@param mw Vec
---@return Vec oo Odd-Odd
---@return Vec eo Even-Odd
---@return Vec oe Odd-Even
---@return Vec ee Even-Even
local function fetch_cursors (mw)
    local mg = mw:round () -- centre point
    local best = {
        ["00"] = {d = math.huge},
        ["01"] = {d = math.huge},
        ["10"] = {d = math.huge},
        ["11"] = {d = math.huge},
    }
    local function f(x,y)
        local p = mg + Vec.new (x,y)
        local dist = (p - mw):mag()
        local t = ("%i%i"):format(p.x%2, p.y%2)
        if dist < best[t].d then
            best[t].d = dist
            best[t].v = p
        end
    end
    f(-1,-1); f( 0,-1); f( 1,-1)
    f(-1, 0); f( 0, 0); f( 1, 0)
    f(-1, 1); f( 0, 1); f( 1, 1)
    return best["11"].v, best["01"].v, best["10"].v, best["00"].v
end

function love.draw ()
	local w, h = love.graphics.getDimensions ()
	local win = Vec.new (w,h)

	love.graphics.origin ()
	love.graphics.translate (win.x/2, win.y/2)
	love.graphics.scale (cam.scale)
	love.graphics.translate (-cam.pos.x, -cam.pos.y)

	love.graphics.setColor (bg_light)
	checkers (win)
	--[[
	love.graphics.rectangle ("fill",-1,-1, 1, 1)
	love.graphics.rectangle ("fill", 0, 0, 1, 1)
	--]]

	Debug ("cam pos: %.2f, %.2f", cam.pos.x, cam.pos.y)
	Debug ("zoom: %.2fpx/tile, %i", cam.scale, cam.zoom)

	local mx, my = love.mouse.getPosition ()
	local m = Vec.new (mx, my)
	local mw = screen_to_world (win, m)
	local mg = mw:round ()
	love.graphics.setLineWidth (0.2)
	Debug ("mouse: %.2f, %.2f, [%i,%i]", mw.x, mw.y, mg.x, mg.y)

    local oo, eo, oe, ee = fetch_cursors (mw)

    love.graphics.setColor (0.5, 0.2, 0.1, 1)
	love.graphics.circle ("fill", oo.x, oo.y, 0.2)
	love.graphics.line (mw.x, mw.y, oo.x, oo.y)

    love.graphics.setColor (0.1, 0.5, 0.2, 1)
	love.graphics.circle ("fill", eo.x, eo.y, 0.2)
	love.graphics.line (mw.x, mw.y, eo.x, eo.y)

    love.graphics.setColor (0.2, 0.1, 0.5, 1)
	love.graphics.circle ("fill", oe.x, oe.y, 0.2)
	love.graphics.line (mw.x, mw.y, oe.x, oe.y)

	love.graphics.setColor (fg_cursor)
	love.graphics.circle ("fill", mg.x, mg.y, 0.2)
	love.graphics.line (mw.x, mw.y, mg.x, mg.y)

	love.graphics.setColor (1,1,1)
    --[[
    for _, s in ipairs (Rail.basic) do
        s:draw ()
    end
    --]]
    love.graphics.line (Rail.basic[idx].path)
    Debug ("idx = %i", idx)

	love.graphics.origin ()
	love.graphics.setColor (1,1,1)
	love.graphics.print (table.concat (Debug_info, "\n"))
	Debug_info = {}
end
