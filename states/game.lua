package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'

require 'arc'
require 'control'
require 'gfx'
require 'player'
require 'status'

-- Main game state.
local game = {}

-- other: init / intermission
function game:enter(other)
    self.states = other.states
    self.shaders = other.shaders
    self.env = other.env
    self.players = other.players
    self.map = other.map

    self.collider = HC.new(100)
    self.map:addToCollider(self.collider)

    self:_resetPlayers()

    self.time = 0
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
    self.time = self.time + dt

    local players = self.players
    local dr = dt * self.env.dt_speedup
    local active = 0
    for i = 1, #players do
        if players[i].alive then
            active = active + 1
            players[i]:update(dr)
            players[i]:detectCollision(self.collider, dr)
        end
    end

    if active <= 1 then
        Gamestate.switch(self.states.intermission)
    end
end

function game:draw()
    drawGame(self.players, self.map, false, self.shaders)
end

function game:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

function game:_resetPlayers()
    local function _resetActive(player, angle)
        local map_x, map_y = self.map.x, self.map.y
        local r = self.map.radius * 0.7
        local arc = Arc:new({
            x = map_x + math.cos(angle) * r,
            y = map_y + math.sin(angle) * r,
            radius = player.active.radius,
            dot_radius = player.active.dot_radius,
            width = player.active.width,
            start_rads = angle,
            end_rads = angle,
            direction = 'cw',
            player = player.active.player
        })
        player:reset(arc)
        player:addToCollider(self.collider)
    end
    _resetActive(self.players[1], math.pi * 5 / 4)
    _resetActive(self.players[2], math.pi * 7 / 4)
    _resetActive(self.players[3], math.pi * 1 / 4)
    _resetActive(self.players[4], math.pi * 3 / 4)
end

return game
