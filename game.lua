require 'test'

require 'arc'
require 'control'
require 'player'
require 'status'

HC = require 'hc'
shapes = require 'hc.shapes'

local game = {}

function game:load()
end

function game:enter(init)
    self.env = init.env
    self.players = init.players
    self.map = init.map
    self:_resetMap() 
    self:_resetPlayers() 
end

function game:keypressed(key, scan_code, is_repeat)
    local players = self.players
    for i = 1, #players do
       players[i]:keypressed(key, collider)
    end
end

function game:touchpressed(id, x, y, dx, dy, pressure)
    local players = self.players
    for i = 1, #players do
       players[i]:touchpressed(x, y, collider)
    end
end

function game:focus(f)
    gameIsPaused = not f
end

function game:update(dt)
    if gameIsPaused then return end
    local players = self.players
    local dr = dt * self.env.dt_speedup
    if self.map.alive then
      self.map.arc:update(4 * dr)
      self.map.alive = not self.map.arc:intersectsSelf()
      if not self.map.alive then
        game:_resetPlayers()
      end
      return
    else
        active = 0
        for i = 1, #players do
            if players[i].alive then
                active = active + 1
                players[i]:update(dr)
                players[i]:detectCollision(collider, dr)
            end
        end
        if active <= 1 then
            for i = 1, #players do
                if players[i].alive then
                    players[i]:won()
                end
            end
            if active == 1 then
                self.env.dt_speedup = self.env.dt_speedup + 0.1
            end
            game:_resetMap()
        end
    end
end

function game:draw()
    for i = 1, #self.players do
       self.players[i]:draw()
    end
    self.map.arc:draw()
    if self.map.alive then
      self.map.arc:drawEndDot()
    end
end

function game:_resetMap()
    self.env.round = self.env.round + 1

    collider = HC.new(100)

    -- total_rads at least 2pi less than 0 so that lines will definitely collide :)
    local map_start_rads = (3 + self.env.round % 4 * 2) * math.pi / 4
    local arc = self.map.arc
    self.map.arc = Arc:new({ x = arc.x, y = arc.y, radius = arc.radius, dot_radius = arc.dot_radius, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })
    self.map.arc:addToCollider(collider)
    self.map.alive = true
end

function game:_resetPlayers()
    local players = self.players
    for i = 1, #players do
        players[i].alive = true
        players[i].trail = {}
    end

    local function _resetActive(player, angle)
        local map_x, map_y = self.map.arc.x, self.map.arc.y
        local r = self.map.arc.radius * 0.7
        player.active = Arc:new({ x = map_x + math.cos(angle) * r, y = map_y + math.sin(angle) * r, radius = player.active.radius, dot_radius = player.active.dot_radius, start_rads = angle, end_rads = angle, direction = 'cw', player = player.active.player })
    end
    _resetActive(players[1], math.pi * 5 / 4)
    _resetActive(players[2], math.pi * 7 / 4)
    _resetActive(players[3], math.pi * 1 / 4)
    _resetActive(players[4], math.pi * 3 / 4)

    for i = 1, #players do
        players[i]:addToCollider(collider)
    end
end

return game
