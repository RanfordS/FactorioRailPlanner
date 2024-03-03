local Vec = require "vec"

function love.load ()
	love.window.setTitle "Factorio Rail Planner"
end

local camera =
{
	pos = Vec.new (0,0),
	zoom = 50,
	speed = 10,
}
function love.update (dt)
	if love.keyboard.isDown "w" then
		camera.pos.y = camera.pos.y - dt*camera.speed
	end
	if love.keyboard.isDown "s" then
		camera.pos.y = camera.pos.y + dt*camera.speed
	end
	if love.keyboard.isDown "a" then
		camera.pos.x = camera.pos.x - dt*camera.speed
	end
	if love.keyboard.isDown "d" then
		camera.pos.x = camera.pos.x + dt*camera.speed
	end
end

-- Factorio's coordinates are as follows, everything developed to match
-- 	#--> x
-- 	|
-- 	V
-- 	y

function checkerboard (center, w, h)
	local left   = center.x - w/2
	local right  = center.x + w/2
	local bottom = center.y + h/2
	local top    = center.y - h/2

	local lc = math.floor (left)
	local rc = math.ceil (right)
	local br = math.ceil (bottom)
	local tr = math.floor (top)

	for r = tr, br-1 do
		local y = r
		for c = lc, rc-1 do
			local x = c
			if (r + c) % 2 == 0 then
				love.graphics.rectangle ("fill", x, y, 1, 1)
			end
		end
	end
end

function screen_to_world (pos)
end

function love.draw ()
	local w, h = love.graphics.getDimensions ()
	local win = Vec.new (w,h)

	love.graphics.origin ()
	love.graphics.scale (camera.zoom)
	local t = win/2 - camera.pos
	love.graphics.translate (t.x, t.y)

	love.graphics.setColor (0.2, 0.2, 0.2, 1)
	checkerboard (camera.pos, w/2, h/2)

	love.graphics.setColor (1.0, 0.5, 0.2, 1)
	love.graphics.rectangle ("fill", camera.pos.x, camera.pos.y, 0.1, 0.1)

	love.graphics.setColor (1.0, 1.0, 1.0, 1)
	love.graphics.print ("Origin", 0, 0)

	love.graphics.origin ()
	love.graphics.print (("cam = %.2f, %.2f"):format (camera.pos.x, camera.pos.y), 0, 0)
end
