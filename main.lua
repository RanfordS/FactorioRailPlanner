---@source love
local Vec = require "vec"
local Rail = require "rail-segment"
local Parity = require "parity"

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

	love.graphics.setColor (bg_light)
	for r = tl.y+dbg_off, br.y-1-dbg_off do
		for c = tl.x+dbg_off, br.x-1-dbg_off do
			if (r + c) % 2 == 0 then
				love.graphics.rectangle ("fill", c, r, 1, 1)
			end
		end
	end
    love.graphics.setColor (1.0, 0.8, 0.5)
	for r = tl.y+dbg_off, br.y-1-dbg_off do
		for c = tl.x+dbg_off, br.x-1-dbg_off do
            if r % 2 == 0 and c % 2 == 0 then
                love.graphics.circle ("fill", c, r, 0.1, 4)
            end
		end
	end
end

local seq = {
    "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
    "c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7",
    "c8", "c9", "cA", "cB", "cC", "cD", "cE", "cF",
}
local idx = 1
function love.mousepressed (x, y, button, istouch, presses)
    idx = (idx % #seq) + 1
end

function love.draw ()
	local w, h = love.graphics.getDimensions ()
	local win = Vec.new (w,h)

	love.graphics.origin ()
	love.graphics.translate (win.x/2, win.y/2)
	love.graphics.scale (cam.scale)
	love.graphics.translate (-cam.pos.x, -cam.pos.y)

	checkers (win)

	Debug ("cam pos: %.2f, %.2f", cam.pos.x, cam.pos.y)
	Debug ("zoom: %.2fpx/tile, %i", cam.scale, cam.zoom)

	local mx, my = love.mouse.getPosition ()
	local m = Vec.new (mx, my)
	local mw = screen_to_world (win, m)
	local mg = mw:round ()
	love.graphics.setLineWidth (0.2)
	Debug ("mouse: %.2f, %.2f, [%i,%i]", mw.x, mw.y, mg.x, mg.y)

    love.graphics.push ()
    ---@type RailSegment
    local obj = Rail[seq[idx]]
    local pos_a = mw + obj.pos_a - obj.pos_c
    pos_a = Parity.closest (pos_a, obj.parity_a)
    local pos = pos_a - obj.pos_a
    love.graphics.translate (pos.x,pos.y)
	love.graphics.setColor (1,1,1)
    love.graphics.polygon ("line", obj.path)
    love.graphics.pop ()
    Debug ("idx = %i", idx)

	love.graphics.origin ()
	love.graphics.setColor (1,1,1)
	love.graphics.print (table.concat (Debug_info, "\n"))
	Debug_info = {}
end
