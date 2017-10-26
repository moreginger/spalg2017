package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'
local shapes = require 'hc.shapes'
local moonshine = require 'moonshine'

require 'arc'
require 'control'
require 'player'
require 'status'
require 'gfx'

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

    local font_size = env.trail_radius * 1.5
    local font = love.graphics.newFont('resources/Taurus-Mono-Outline-Regular.otf', font_size)
    self.status_tmpl = Status:new({ font = font, display_w = font_size * 3, display_h = font_size })

    self.shaders.trail = moonshine(moonshine.effects.fastgaussianblur)
    self.shaders.trail.parameters = {
        fastgaussianblur = {
            taps = 9,
            offset = env.trail_width, -- Compensation for HDPI with mandatory low taps.
            offset_type = 'center'
        }
    }
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
    self.map = Arc:new({x = env.screen_x / 2, y = env.screen_y / 2, radius = map_radius, dot_radius = dot_radius * 1.5, width = env.trail_width})

    local display_offset = trail_radius * 2;
    -- TODO don't duplicate end_rads start position here.
    self.players[1] = Player:new({
        control = Control:new({ key = 'q', region = touchBox(0, 0) }),
        status = self.status_tmpl:new({ display_x = display_offset, display_y = display_offset }),
        active = arc:new({player = 1, end_rads = math.pi * 5 / 4})
    })
    self.players[2] = Player:new({
        control = Control:new({ key = 'p', region = touchBox(env.screen_x - touch_x, 0) }),
        status = self.status_tmpl:new({ display_x = env.screen_x - display_offset, display_y = display_offset }),
        active = arc:new({player = 2, end_rads = math.pi * 7 / 4})
    })
    self.players[3] = Player:new({
        control = Control:new({ key = '.', region = touchBox(env.screen_x - touch_x, env.screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_x = env.screen_x - display_offset, display_y = env.screen_y - display_offset }),
        active = arc:new({player = 3, end_rads = math.pi * 1 / 4})
    })
    self.players[4] = Player:new({
        control = Control:new({ key = 'z', region = touchBox(0, env.screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_x = display_offset, display_y = env.screen_y - display_offset }),
        active = arc:new({player = 4, end_rads = math.pi * 3 / 4})
    })
end

function init:update(dt)
    local dr = dt * self.env.dt_speedup
    self.map:update(4 * dr)
    if self.map:intersectsSelf() then
        Gamestate.switch(self.states.game)
    end
end

function init:draw()
    drawGame(self.players, self.map, true, self.shaders)
end

function init:focus(focus)
    if not focus then
        Gamestate.push(self.states.pause)
    end
end

return init
