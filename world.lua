local Utils = require "utils"
local RailInstance = require "rail-instance"
local Vec = require "vec"

---@class World
---@field ground RailInstance[]
---@field raised RailInstance[]
local World = {}
World.__index = World

---@param tab table?
---@return World
function World.new (tab)
    tab = tab or {}
    return setmetatable ({
        ground  = tab.ground  or {},
        raised  = tab.raised  or {},
        ramps   = tab.ramps   or {},
        pillars = tab.pillars or {},
    },  World)
end

---@return string
function World:serialize ()
    local ground = table.concat (Utils.array_func (self.ground, RailInstance.serialize), ",")
    local raised = table.concat (Utils.array_func (self.raised, RailInstance.serialize), ",")
    local ramps  = ""
    local pillars = ""
    return ([[W{ground={%s},raised={%s},ramps={%s},pillars={%s}}]]):format (
                ground,     raised,     ramps,     pillars)
end

---@param body_str string
---@return World
function World.load (body_str)
    local func_str = ([[return function (W,RI,V)
        return %s
    end]]):format (body_str)
    local outer_func, load_err = load (func_str)
    setfenv (outer_func, {})
    assert (outer_func, "Failed to load func_str: "..tostring (load_err))
    local inner_func = outer_func ()
    setfenv (inner_func, {})
    local res = inner_func (World.new, RailInstance.new, Vec.new)
    return res
end

function World:select (pos)
    local list = {}
    local list_i = {}
    for i, instance in ipairs (self.ground) do
        if instance:contains (pos) then
            table.insert (list, instance)
            table.insert (list_i, tostring (i))
        end
    end
    return list, table.concat (list_i,",")
end

return World
