package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local gfx = require 'gfx'

-- Post game state.
local fin = {}

function fin:enter(other)
    self.env = other.env
    self.state = other.state
    self.states = other.states

    self.time = 0
    self.can_leave = false
end

function fin:update(dt)
    self.time = self.time + dt
    if self.time > 2 then
        self.can_leave = true
    end
end

function fin:draw()
    gfx.drawGame(self.state, false)
    if self.can_leave then
        gfx.drawLogo()
    end
end

function fin:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

function fin:keypressed(key, scan_code, is_repeat)
    self:_reset()
end

function fin:touchpressed(id, x, y, dx, dy, pressure)
    self:_reset()
end

function fin:_reset()
    if self.can_leave then
        self.states.init:reset()
        Gamestate.switch(self.states.init)
    end
end

return fin
