local Utils = {}

---@generic A
---@generic B
---@param array A[]
---@param func function(elem: A, ...: any):B
---@param ... any
---@return B[]
function Utils.array_func (array, func, ...)
    local res = {}
    for i, v in ipairs (array) do
        res[i] = func (v, ...)
    end
    return res
end

---@param switch string
---@param cases {[string]: function}
function Utils.switch (switch, cases)
    local case = cases[switch]
    if case then return case() end
    case = cases.default
    if case then return case() end
    error ("Unhandled case `"..switch.."` in switch")
end

return Utils
