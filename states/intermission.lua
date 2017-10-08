package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local game = require 'states.game'

-- Short intermission between rounds
local intermission = {}

-- other = init or game.
function intermission:enter(other)
    self.env = other.env
    self.map = other.map
    self.players = other.players

    local map_start_rads = (3 + self.env.round % 4 * 2) * math.pi / 4
    local arc = self.map.arc
    -- total_rads at least 2pi less than 0 so that lines will defotherely collide :)
    self.map.arc = Arc:new({ x = arc.x, y = arc.y, radius = arc.radius, dot_radius = arc.dot_radius, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })
    self.map.arc:addToCollider(collider)
    self.map.alive = true
end

function intermission:update(dt)
    local dr = dt * self.env.dt_speedup
    self.map.arc:update(4 * dr)
    if self.map.arc:intersectsSelf() then
        Gamestate.switch(game)
    end
end

function game:draw()
    self.map.arc:draw()
    self.map.arc:drawEndDot()

    for i = 1, #self.players do
       self.players[i]:draw()
    end
end