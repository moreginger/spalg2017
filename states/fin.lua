package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

-- Post game state.
local fin = {}

function fin:enter(game)
    self.states = game.states
    self.shaders = game.shaders
    self.env = game.env
    self.players = game.players
    self.map = game.map

    self.time = 0
end

function fin:update(dt)
    self.time = self.time + dt
    local noSwitch = false
    for i = 1, #self.players do
        local status = self.players[i].status
        status:subWins(self.time / 10)
        if status.wins > 0 then
            noSwitch = true
        end
    end
    if not noSwitch then
        Gamestate.switch(self.states.init)
    end
end

function fin:draw()
    self.shaders.trail:draw(function()
        self:_draw(self.shaders.cfg_trails)
    end)
    self:_draw(self.shaders.cfg_all)
end

function fin:_draw(cfg)
    for i = 1, #self.players do
       self.players[i]:draw(cfg)
    end
    self.map:draw()
end

function fin:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return fin
