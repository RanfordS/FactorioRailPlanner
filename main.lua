---@source love
local Vec = require "vec"
local Rail = require "rail-segment"
local RailInstance = require "rail-instance"
local Parity = require "parity"
local View = require "view"
local colors = require "colors"
local settings = require "settings"
local World = require "world"
local Utils = require "utils"
local positioning = require "positioning"

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

local current_view = View.new ()
local current_world = World.new ()

function love.load ()
	love.graphics.setBackgroundColor (colors.bg_dark)
end

function love.wheelmoved (x, y)
	if 0 < y then
        current_view:zoom_in ()
	elseif y < 0 then
        current_view:zoom_out ()
	end
end

local cam_movement = {
	w = Vec.new ( 0,-1),
	s = Vec.new ( 0, 1),
	a = Vec.new (-1, 0),
	d = Vec.new ( 1, 0),
}

function love.update (dt)
	local speed = love.keyboard.isDown "lshift" and settings.shift_speed or settings.base_speed
	speed = speed/current_view.scale
	for k, v in pairs (cam_movement) do
		if love.keyboard.isDown (k) then
            Debug ("key down: %s", k)
			current_view.world_pos = current_view.world_pos + v*dt*speed
		end
	end
end

local obj = RailInstance.new ("c0", Vec.new (10,0))
table.insert (current_world.ground, obj)

local seq = {
    "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7",
    "c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7",
    "c8", "c9", "cA", "cB", "cC", "cD", "cE", "cF",
}
local idx = 1
function love.mousepressed (x, y, button, istouch, presses)
    idx = (idx % #seq) + 1
    obj.segment = seq[idx]
end

function love.draw ()
	local w, h = love.graphics.getDimensions ()
	current_view.dimensions = Vec.new (w,h)
    current_view:love_transform ()

	current_view:checkers ()

	Debug ("current_view pos: %.2f, %.2f", current_view.world_pos.x, current_view.world_pos.y)
	Debug ("zoom: %.2fpx/tile, %i", current_view.scale, current_view.zoom)

	local mx, my = love.mouse.getPosition ()
	local m = Vec.new (mx, my)
	local mw = current_view:screen_to_world_pos (m)
	local mg = mw:round ()
	love.graphics.setLineWidth (0.1)
	Debug ("mouse: %.2f, %.2f, [%i,%i]", mw.x, mw.y, mg.x, mg.y)

    local seg = obj:get_segment ()
    obj.pos = positioning.snap (mw, seg.pos_c, seg.pos_a, seg.parity_a)
	love.graphics.setColor (1,1,1)
    obj:draw ()
    obj:draw_signals ()
    Debug ("idx = %i, %s", idx, seq[idx])
    Debug ("inside = %s", tostring (obj:contains (mw)))

    Debug (current_world:serialize ())
    local test = current_world:serialize ()
    Debug (World.load (test):serialize ())

	love.graphics.origin ()
	love.graphics.setColor (1,1,1)
	love.graphics.print (table.concat (Debug_info, "\n"))
	Debug_info = {}
end


local seg_type = "s"
local ang = 0

function love.keypressed (key, scancode, isrepeat)
    Utils.switch (key,
    {   s = function ()
            seg_type = "s"
        end,
        c = function ()
            seg_type = "c"
        end,
        r = function ()
            local seg = obj.segment
            if love.keyboard.isDown "lshift" then
                obj.segment = Rail.map_rotate_anticlock[seg]
            else
                obj.segment = Rail.map_rotate_clock[seg]
            end
        end,
        default = function () end
    })
end

