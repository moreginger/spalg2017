package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'
local tween = require 'tween.tween'

require 'gfx'

-- Short intermission between rounds
local intermission = {
    name = 'intermission',
    dot_tween = nil,
    status_tweens = {}
}

local _firstToWins = 25

-- other: game.
function intermission:enter(other)
    self.states = other.states
    self.shaders = other.shaders
    self.env = other.env
    self.map = other.map
    self.players = other.players
    self.dot_tween = nil

    local playing = 0;
    for i = 1, #self.players do
        local p = self.players[i]
        if p:playing() then
            playing = playing + 1
        end
        self.status_tweens[i] = tween.new(math.pi, { angle = p.status.angle % 2 * math.pi + 2 * math.pi }, { angle = p.start_rads }, 'inOutCubic')
    end
    if playing > 0 then
        for i = 1, #self.players do
            if self.players[i].alive then
                -- Won a round
                self.players[i].alive = false
                if self.players[i]:won() >= _firstToWins then
                    self.env.winner = i
                end
                local start_pos = self.players[i].active:endPos()
                local end_pos = { x = self.players[i].status.display_x, y = self.players[i].status.display_y }
                self.dot_tween = tween.new(math.pi, start_pos, end_pos, 'inCubic')
            end
        end
    end
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
    local dr = 4 * dt * self.env.dt_speedup
    self.map:update(dr)
    if self.dot_tween ~= nil then
        self.dot_tween:update(dr)
    end
    for i = 1, #self.status_tweens, 1 do
        local t = self.status_tweens[i]
        t:update(dr)
        self.players[i].status.angle = t.subject.angle
    end
    if self.map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function intermission:draw()
    drawGame(self.players, self.map, true, self.shaders)
    if self.dot_tween ~= nil then
        love.graphics.circle('line', self.dot_tween.subject.x, self.dot_tween.subject.y, 5)
    end
end

function intermission:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return intermission
