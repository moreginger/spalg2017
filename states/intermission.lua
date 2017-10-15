package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

-- Short intermission between rounds
local intermission = {
    name = 'intermission'
}

-- other = init or game.
function intermission:enter(other)
    self.states = other.states
    self.shaders = other.shaders
    self.env = other.env
    self.map = other.map
    self.players = other.players

    local map_start_rads = (3 + self.env.round % 4 * 2) * math.pi / 4
    local arc = self.map
    -- total_rads at least 2pi less than 0 so that lines will defotherely collide :)
    self.map = Arc:new({ x = arc.x, y = arc.y, radius = arc.radius, dot_radius = arc.dot_radius, width = arc.width, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })
end

function intermission:update(dt)
    local dr = dt * self.env.dt_speedup
    self.map:update(4 * dr)
    if self.map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function intermission:draw()
    self:_draw(self.shaders.cfg_all)
end

function intermission:_draw(cfg)
    for i = 1, #self.players do
        self.players[i]:draw(cfg)
    end
    self.map:draw()
    self.map:drawEndDot(1)
end

function intermission:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return intermission
