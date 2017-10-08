package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'

require 'arc'
require 'control'
require 'player'
require 'status'

local pause = require 'states.pause'

local game = {}

function game:enter(intermission)
    self.env = intermission.env
    self.players = intermission.players
    self.map = intermission.map

    self.state_intermission = intermission

    self.collider = HC.new(100)
    self.map:addToCollider(self.collider)

    self:_resetPlayers()
end

function game:leave()
    self.env.dt_speedup = self.env.dt_speedup + 0.1
    self.env.round = self.env.round + 1
end

function game:keypressed(key, scan_code, is_repeat)
    local players = self.players
    for i = 1, #players do
       players[i]:keypressed(key, self.collider)
    end
end

function game:touchpressed(id, x, y, dx, dy, pressure)
    local players = self.players
    for i = 1, #players do
       players[i]:touchpressed(x, y, self.collider)
    end
end

function game:update(dt)
    local players = self.players
    local dr = dt * self.env.dt_speedup
    active = 0
    for i = 1, #players do
        if players[i].alive then
            active = active + 1
            players[i]:update(dr)
            players[i]:detectCollision(self.collider, dr)
        end
    end
    if active <= 1 then
        for i = 1, #players do
            if players[i].alive then
                players[i]:won()
            end
        end
        Gamestate.switch(self.state_intermission)
    end
end

function game:draw()
    for i = 1, #self.players do
       self.players[i]:draw()
    end
    self.map:draw()
end

function game:focus(focus)
    if not focus then
        Gamestate.push(pause)
    end
end

function game:_resetPlayers()
    local players = self.players
    for i = 1, #players do
        players[i].alive = true
        players[i].trail = {}
    end

    local function _resetActive(player, angle)
        local map_x, map_y = self.map.x, self.map.y
        local r = self.map.radius * 0.7
        player.active = Arc:new({ x = map_x + math.cos(angle) * r, y = map_y + math.sin(angle) * r, radius = player.active.radius, dot_radius = player.active.dot_radius, start_rads = angle, end_rads = angle, direction = 'cw', player = player.active.player })
    end
    _resetActive(players[1], math.pi * 5 / 4)
    _resetActive(players[2], math.pi * 7 / 4)
    _resetActive(players[3], math.pi * 1 / 4)
    _resetActive(players[4], math.pi * 3 / 4)

    for i = 1, #players do
        players[i]:addToCollider(self.collider)
    end
end

return game
