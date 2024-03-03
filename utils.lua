local Utils = {}

function Utils.array_func (array, func, ...)
    local res = {}
    for i, v in ipairs (array) do
        res[i] = func (v, ...)
    end
    return res
end

return Utils
