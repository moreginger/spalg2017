package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local gfx = require 'gfx'

-- Short intermission between rounds
local intermission = {
    name = 'intermission'
}

-- other: game.
function intermission:enter(other)
    self.states = other.states
    self.env = other.env
    self.map = other.map
    self.players = other.players

    local playing = 0;
    for i = 1, #self.players do
        local p = self.players[i]
        if p:playing() then
            playing = playing + 1
        end
    end

    local winner = 0
    for i = 1, #self.players do
        local player = self.players[i]
        if player.alive then
            if player:updateScore(3) then
                winner = i
            end
        else
            player:updateScore(-1)
        end
    end

    if winner ~= 0 or playing == 0 then
        Gamestate.switch(self.states.fin)
    else
        local map_start_rads = (3 + self.env.round % 4 * 2) * math.pi / 4
        local arc = self.map
        -- total_rads at least 2pi less than 0 so that lines will defotherely collide :)
        self.map = Arc:new({ x = arc.x, y = arc.y, radius = arc.radius, dot_radius = arc.dot_radius, width = arc.width, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })   
    end
end

function intermission:update(dt)
    local dr = 4 * dt * self.env.dt_speedup
    self.map:update(dr)
    if self.map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function intermission:draw()
    gfx.drawGame(self.players, self.map, true)
end

function intermission:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return intermission
