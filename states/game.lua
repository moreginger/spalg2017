package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'

require 'arc'
require 'control'
local gfx = require 'gfx'
require 'player'
require 'status'

-- Main game state.
local game = {}

-- other: init / intermission
function game:enter(other)
    self.env = other.env
    self.state = other.state
    self.states = other.states

    self.collider = HC.new(100)
    self.state.map:addToCollider(self.collider)

    self:_resetPlayers()
end

function game:leave()
    self.state.round = self.state.round + 1
end

function game:keypressed(key, scan_code, is_repeat)
    local players = self.state.players
    for i = 1, #players do
       players[i]:keypressed(key, self.collider)
    end
end

function game:touchpressed(id, x, y, dx, dy, pressure)
    local state = self.state
    local players = state.players
    if state.map.co:contains(x, y) then
        -- Mask play area to help discourage attempts to interact with it.
    else
        for i = 1, #players do
           players[i]:touchpressed(x, y, self.collider)
        end
    end
end

function game:update(dt)
    local env = self.env
    local state = self.state
    local players = state.players

    state.time_played = state.time_played + dt
    local game_speed = env.min_speed + (env.max_speed - env.min_speed) * math.min(1, (state.time_played / env.speedup_time))
    local dr = dt * game_speed
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
    gfx.drawGame(self.state, false)
end

function game:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

function game:_resetPlayers()
    local state = self.state
    local map = state.map
    local players = state.players
    local map_x, map_y = map.x, map.y
    local r = map.radius * 0.7
    for i = 1, #players, 1 do
        local p = players[i]
        local angle = p.start_rads
        local arc = Arc:new({
            x = map_x + math.cos(angle) * r,
            y = map_y + math.sin(angle) * r,
            radius = p.active.radius,
            dot_radius = p.active.dot_radius,
            width = p.active.width,
            start_rads = angle,
            end_rads = angle,
            direction = 'cw',
            player = p.active.player
        })

        -- TODO move arc construction in here?
        p:reset(arc)
        p:addToCollider(self.collider)
    end
end

return game
