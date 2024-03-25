local Vec = require "vec"
local colors = require "colors"
local settings = require "settings"

---@class View
---@field screen_pos Vec
---@field dimensions Vec
---@field world_pos Vec
---@field zoom integer Zoom level.
---@field scale number Actual visual scale.
local View = {}
View.__index = View

---@return View
function View.new ()
    return setmetatable (
    {   screen_pos = Vec.new (0,0),
        dimensions = Vec.new (600,800),
        world_pos  = Vec.new (0,0),
        zoom = 8,
        scale = 2.0^4
    },  View)
end

function View:zoom_in ()
    self:set_zoom (self.zoom + 1)
end

function View:zoom_out ()
    self:set_zoom (math.max (self.zoom - 1, 0))
end

function View:set_zoom (z)
	self.zoom = z
	self.scale = 2^(z/2)
end

---@param pos Vec
---@return Vec
function View:screen_to_world_pos (pos)
    local view_center = self.screen_pos + self.dimensions/2
	return (pos - view_center)/self.scale + self.world_pos
end

---@param instances RailInstance[]
function View:draw (instances)
    local view_top_left = self.screen_pos
    local view_bot_right = self.screen_pos + self.dimensions
    for _, instance in pairs (instances) do
        local seg = self:get_segment ()
        if seg.bot_right.x < view_top_left.x
        or seg.bot_right.y < view_top_left.y
        or view_bot_right.x < seg.top_left.x
        or view_bot_right.y < seg.top_left.y
        then
        else
            instance:draw ()
        end
    end
end

function View:checkers ()
	local tl = self:screen_to_world_pos (Vec.new (0,0)):floor ()
	local br = self:screen_to_world_pos (self.dimensions):ceil ()

	local dbg_off = 0

	love.graphics.setColor (colors.bg_light)
	for r = tl.y+dbg_off, br.y-1-dbg_off do
		for c = tl.x+dbg_off, br.x-1-dbg_off do
			if (r + c) % 2 == 0 then
				love.graphics.rectangle ("fill", c, r, 1, 1)
			end
		end
	end
    love.graphics.setColor (colors.bg_corner_marker)
	for r = tl.y+dbg_off, br.y-1-dbg_off do
		for c = tl.x+dbg_off, br.x-1-dbg_off do
            if r % 2 == 0 and c % 2 == 0 then
                love.graphics.circle ("fill", c, r, 0.1, 4)
            end
		end
	end
end

function View:love_transform ()
    local w = self.dimensions/2
    local p = 0-self.world_pos
	love.graphics.origin ()
	love.graphics.translate (w.x, w.y)
	love.graphics.scale (self.scale)
	love.graphics.translate (p.x, p.y)
end

return View
