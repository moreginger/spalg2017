package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'
local tween = require 'tween.tween'

local gfx = require 'gfx'

-- Short intermission between rounds
local intermission = {
    name = 'intermission',
    status_tweens = {}
}

local _firstToWins = 25

-- other: game.
function intermission:enter(other)
    self.states = other.states
    self.env = other.env
    self.map = other.map
    self.players = other.players

    self.winner = nil

    local playing = 0;
    for i = 1, #self.players do
        local p = self.players[i]
        if p:playing() then
            playing = playing + 1
        end
        local start_angle = p.status.angle % (2 * math.pi)
        self.status_tweens[i] = tween.new(2 * math.pi, { angle = start_angle }, { angle = p.start_rads }, 'inOutCubic')
    end
    if playing > 0 then
        for i = 1, #self.players do
            if self.players[i].alive then
                -- Won a round
                self.players[i].alive = false
                local start_pos = self.players[i].active:endPos()
                self.players[i].status:prepareWin(start_pos)
                self.winner = { index = i }
            end
        end
    end
    if playing == 0 then
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
    for i = 1, #self.status_tweens, 1 do
        local t = self.status_tweens[i]
        t:update(dr)
        self.players[i].status:update(dr, t.subject.angle)
    end
    if self.map:intersectsSelf() then
        local fin = false
        for i = 1, #self.players, 1 do
            fin = self.players[i].status:confirmWin() >= _firstToWins or fin
        end
        if fin then
            Gamestate.switch(self.states.fin)
        else
            Gamestate.switch(self.states.game)
        end
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
