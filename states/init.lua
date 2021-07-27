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
        screen_x,
        screen_y,
        trail_radius,
        trail_width,
        dt_speedup = 1,
        round = 0
    },
    map = nil,
    players = {},
    states = {},
    shaders = {}
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

    local font_size = env.trail_radius * 3
    self.states.pause.font = love.graphics.newFont('resources/comfortaa.bold.ttf', font_size)
    self.status_tmpl = Status:new({ dot_size = env.trail_radius / 8, step_size = env.trail_radius / 2 })
    self.shaders.cfg_all = { trails = true, status = true }
end

function init:enter()
    local env = self.env

    env.dt_speedup = 1
    env.round = 0
    env.winner = 0

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
    self.map = Arc:new({x = env.screen_x / 2, y = env.screen_y / 2, radius = map_radius, dot_radius = dot_radius * 1.5, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, width = env.trail_width})

    local display_offset = trail_radius * 2;
    self.players[1] = Player:new({
        control = Control:new({ key = 'q', region = touchBox(0, 0) }),
        status = self.status_tmpl:new({ display_v = vector(display_offset, display_offset) })
    })
    self.players[2] = Player:new({
        control = Control:new({ key = 'p', region = touchBox(env.screen_x - touch_x, 0) }),
        status = self.status_tmpl:new({ display_v = vector(env.screen_x - display_offset, display_offset) })
    })
    self.players[3] = Player:new({
        control = Control:new({ key = '.', region = touchBox(env.screen_x - touch_x, env.screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_v = vector(env.screen_x - display_offset, env.screen_y - display_offset) })
    })
    self.players[4] = Player:new({
        control = Control:new({ key = 'z', region = touchBox(0, env.screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_v = vector(display_offset, env.screen_y - display_offset) })
    })
    for i = 1, #self.players, 1 do
        local p = self.players[i]
        local start_rads = (3 + i * 2) % 8 / 4 * math.pi
        p.start_rads = start_rads
        p.active = arc:new({player = i, start_rads = start_rads, end_rads = end_rads})
        p.status:update(0, start_rads)
    end
    Gamestate.push(self.states.pause)
end

function init:update(dt)
    local dr = dt * self.env.dt_speedup
    self.map:update(4 * dr)
    if self.map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function init:draw()
    gfx.drawGame(self.players, self.map, true)
end

function init:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return init
