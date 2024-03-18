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

return Utils
