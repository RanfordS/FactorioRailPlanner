local RailSegment = require "rail-segment"

---@class RailInstance
---@field segment string
---@field pos Vec
local RailInstance = {}
RailInstance.__index = RailInstance

---@param seg string
---@param pos Vec
---@return RailInstance
function RailInstance.new (seg, pos)
    return setmetatable (
    {   segment = seg,
        pos = pos,
    },  RailInstance)
end

function RailInstance:draw ()
    local seg = self:get_segment ()
    love.graphics.push ()
    love.graphics.translate (self.pos.x, self.pos.y)
    love.graphics.polygon ("line", seg.path)
    love.graphics.pop ()
end

function RailInstance:draw_signals ()
    local s = 0.5
    local b = 0.2*s
    love.graphics.push ()
    love.graphics.translate (self.pos.x, self.pos.y)
    local seg = RailSegment[self.segment]
    for _, p in ipairs (seg.signal_a2b) do
        if p ~= false then
            love.graphics.rectangle ("line", p.x - s/2, p.y - s/2, s, s, b, b, 8)
        end
    end
    for _, p in ipairs (seg.signal_b2a) do
        if p ~= false then
            love.graphics.rectangle ("line", p.x - s/2, p.y - s/2, s, s, b, b, 8)
        end
    end
    love.graphics.pop ()
end

---@return RailSegment
function RailInstance:get_segment ()
    return RailSegment[self.segment]
end

function RailInstance:contains (p)
    return self:get_segment ():contains (p - self.pos)
end

return RailInstance
