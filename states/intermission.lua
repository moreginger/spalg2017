package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

require 'gfx'

-- Short intermission between rounds
local intermission = {
    name = 'intermission'
}

local _firstToWins = 2

-- other: game.
function intermission:enter(other)
    self.states = other.states
    self.shaders = other.shaders
    self.env = other.env
    self.map = other.map
    self.players = other.players

    local playing = 0;
    for i = 1, #self.players do
        if self.players[i]:playing() then
            playing = playing + 1
        end
    end
    if playing > 0 then
        for i = 1, #self.players do
            if self.players[i].alive then
                if self.players[i]:won() >= _firstToWins then
                    self.env.winner = i
                end
            end
        end
    end
    print(playing, self.env.winner)
    if playing == 0 or self.env.winner > 0 then
        Gamestate.switch(self.states.fin)
    else
        local map_start_rads = (3 + self.env.round % 4 * 2) * math.pi / 4
        local arc = self.map
        -- total_rads at least 2pi less than 0 so that lines will defotherely collide :)
        self.map = Arc:new({ x = arc.x, y = arc.y, radius = arc.radius, dot_radius = arc.dot_radius, width = arc.width, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })
    end
end

function intermission:update(dt)
    local dr = dt * self.env.dt_speedup
    self.map:update(4 * dr)
    if self.map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function intermission:draw()
    drawGame(self.players, self.map, true, self.shaders)
end

function intermission:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return intermission
