package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

-- Game is paused
local pause = {}

function pause:enter(previous)
    self.previous = previous
end

function pause:draw()
    self.previous:draw()
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
