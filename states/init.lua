package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'
local shapes = require 'hc.shapes'
local vector = require 'hump.vector'

require 'arc'
require 'control'
require 'player'
require 'status'
local gfx = require 'gfx'

local intermission = require 'states.intermission'
local game = require 'states.game'
local fin = require 'states.fin'
local pause = require 'states.pause'

-- (re)initialize game state
local init = {
    env = {
        debug_save = os.getenv('SPALG_DEBUG_SAVE') == 'true' and true or false,
        min_speed = 0.25 * math.pi, -- Speed in radians / s.
        max_speed = 4 * math.pi,
        speedup_time = 240, -- Time to reach max speed in s.
        screen_x = 0,
        screen_y = 0,
        trail_radius = 0,
        trail_width = 0,
    },
    state = {
        players = {},
        time_played = 0,
        round = 0,
    },
    map = nil,
    states = {},
}

function init:init()
    -- States object to avoid cyclical deps.
    self.states.init = init
    self.states.intermission = intermission
    self.states.game = game
    self.states.fin = fin
    self.states.pause = pause

    local screen_x, screen_y, flags = love.window.getMode()
    local env = self.env
    env.screen_x = screen_x
    env.screen_y = screen_y
    env.trail_radius = math.min(screen_x, screen_y) / 16
    env.trail_width = math.max(1, math.floor(env.trail_radius / 32))

    gfx.init(env.trail_width, env.trail_radius)

    self.status_tmpl = Status:new({ font = gfx.statusFont(), line_width = env.trail_width, radius = env.trail_radius * 1.5 })

    self:reset()
end

function init:enter()
    Gamestate.push(self.states.pause)
end

function init:reset()
    local env = self.env
    local state = self.state
    local players = state.players

    state.time_played = 0
    state.round = 0

    local touch_x = env.screen_x * 4 / 9
    local touch_y = env.screen_y * 4 / 9
    local function touchBox(x, y)
        local box = shapes.newPolygonShape(0, 0, touch_x, 0, touch_x, touch_y, 0, touch_y)
        box:moveTo(x + touch_x / 2, y + touch_y / 2) -- 0, 0 is center
        return box
    end

    local trail_radius = env.trail_radius
    local dot_radius = trail_radius / 8
    local arc = Arc:new({x = -trail_radius, y = -trail_radius, radius = trail_radius, dot_radius = dot_radius, width = width})

    local map_radius = math.min(env.screen_x, env.screen_y) / 2.05 -- Fit onscreen
    local map_start_rads = 3 * math.pi / 4
    state.map = Arc:new({x = env.screen_x / 2, y = env.screen_y / 2, radius = map_radius, dot_radius = dot_radius * 1.5, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, width = env.trail_width})

    local display_offset = trail_radius * 2;
    players[1] = Player:new({
        control = Control:new({ key = 'q', region = touchBox(0, 0) }),
        status = self.status_tmpl:new({ display_v = vector(display_offset, display_offset), display_angle = math.pi * 0.75 })
    })
    players[2] = Player:new({
        control = Control:new({ key = 'p', region = touchBox(env.screen_x - touch_x, 0) }),
        status = self.status_tmpl:new({ display_v = vector(env.screen_x - display_offset, display_offset), display_angle = math.pi * 1.25 })
    })
    players[3] = Player:new({
        control = Control:new({ key = '.', region = touchBox(env.screen_x - touch_x, env.screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_v = vector(env.screen_x - display_offset, env.screen_y - display_offset), display_angle = math.pi * 1.75 })
    })
    players[4] = Player:new({
        control = Control:new({ key = 'z', region = touchBox(0, env.screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_v = vector(display_offset, env.screen_y - display_offset), display_angle = math.pi * 2.25 })
    })
    for i = 1, #players, 1 do
        local p = players[i]
        local start_rads = (3 + i * 2) % 8 / 4 * math.pi
        p.start_rads = start_rads
        p.active = arc:new({player = i, start_rads = start_rads, end_rads = end_rads})
    end
end

function init:update(dt)
    local players = self.state.players
    for i = 1, #players, 1 do
        local p = players[i]
        p.status.playing = true
    end
    Gamestate.switch(self.states.intermission)
end

function init:draw()
    gfx.drawGame(self.state, true)
end

function init:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return init
