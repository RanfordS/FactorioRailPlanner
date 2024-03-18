---@meta

love = {}
love.graphics = {}

---@enum (key) DrawMode
DrawMode = {
    fill = 1,
    line = 2,
}

---@param mode DrawMode
---@param x number
---@param y number
---@param radius number
---@param segments integer?
function love.graphics.circle (mode, x, y, radius, segments) end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param ... number?
---@overload fun(points:number[])
function love.graphics.line (x1, y1, x2, y2, ...) end

---@param mode DrawMode
---@param x number
---@param y number
---@param width number
---@param height number
---@param rx number?
---@param ry number?
---@param segments integer?
function love.graphics.rectangle (mode, x, y, width, height, rx, ry, segments) end

---@param red number
---@param green number
---@param blue number
---@param alpha number?
---@overload fun(rgb: number[])
function love.graphics.setBackgroundColor (red, green, blue, alpha) end

---@param red number
---@param green number
---@param blue number
---@param alpha number?
---@overload fun(rgb: number[])
function love.graphics.setColor (red, green, blue, alpha) end



