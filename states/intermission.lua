package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local gfx = require 'gfx'

-- Short intermission between rounds
local intermission = {
    name = 'intermission'
}

-- other: game.
function intermission:enter(other)
    self.env = other.env
    self.state = other.state
    self.states = other.states

    local state = self.state
    local players = state.players
    local playing = 0;
    for i = 1, #players do
        local p = players[i]
        if p:playing() then
            playing = playing + 1
        end
    end

    local winner = 0
    local win_points = playing - 1
    for i = 1, #players do
        local player = players[i]
        if player.alive then
            player:finishedGame(win_points)
            if player:hasWon() then
                winner = i
            end
        else
            player:finishedGame(win_points and (win_points / (playing - 1)) or 0)
        end
    end

    if winner ~= 0 or playing == 0 then
        Gamestate.switch(self.states.fin)
    else
        local map_start_rads = (3 + state.round % 4 * 2) * math.pi / 4
        local arc = state.map
        -- total_rads at least 2pi less than 0 so that lines will defotherely collide :)
        state.map = Arc:new({ x = arc.x, y = arc.y, radius = arc.radius, dot_radius = arc.dot_radius, width = arc.width, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })   
    end
end

function intermission:update(dt)
    local map = self.state.map
    -- FIXME
    local dr = 4 * dt
    map:update(dr)
    if map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function intermission:draw()
    gfx.drawGame(self.state, true)
end

function intermission:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return intermission
