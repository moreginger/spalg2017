package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

-- Game is paused
local pause = {
    font = nil,
    canvas = nil
}

function pause:enter(previous)
    self.previous = previous
    self.shaders = previous.shaders
    self.canvas = nil
end

function pause:draw()
    if self.canvas == nil then
        local originalCanvas = love.graphics.getCanvas()

        local source, blurred = love.graphics.newCanvas(), love.graphics.newCanvas()
        love.graphics.setCanvas(source)
        self.previous:draw()

        love.graphics.setCanvas(blurred)
        self.shaders.pause:draw(function()
            love.graphics.draw(source, 0, 0)
        end)

        love.graphics.setCanvas(originalCanvas)

        self.canvas = blurred
    end

    love.graphics.setFont(self.font)
    love.graphics.print('spalg', 10, 10)
    love.graphics.draw(self.canvas, 0, 0)
end

function pause:focus(f)
    if f then
        Gamestate.pop()
    end
end

function pause:keypressed(key, scan_code, is_repeat)
    Gamestate.pop()
end

function pause:touchpressed(id, x, y, dx, dy, pressure)
    Gamestate.pop()
end

return pause
