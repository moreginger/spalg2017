package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'
local shapes = require 'hc.shapes'
local shine = require 'shine'

require 'arc'
require 'control'
require 'player'
require 'status'

local intermission = require 'states.intermission'
local game = require 'states.game'
local fin = require 'states.fin'
local pause = require 'states.pause'

-- (re)initialize game state
local init = {
    env = {
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
    local radius = math.min(screen_x, screen_y) / 16

    local font_size = radius * 1.5
    local font = love.graphics.newFont('resources/Taurus-Mono-Outline-Regular.otf', font_size)
    self.status_tmpl = Status:new({ font = font, display_w = font_size * 3, display_h = font_size })

    self.shaders.trail = shine.bilineargaussianblur({ taps = 13, offset = 2 })
    self.shaders.trail2 = shine.bilineargaussianblur({ taps = 25, offset = 1 })
    self.shaders.cfg_all = { trails = true, status = true }
    self.shaders.cfg_trails = { trails = true, status = false }
end

function init:enter()
    self.env.dt_speedup = 1
    self.env.round = 0

    -- TODO don't duplicate code with init.
    local screen_x, screen_y, flags = love.window.getMode()
	local radius = math.min(screen_x, screen_y) / 16
    local map_x = screen_x / 2
    local map_y = screen_y / 2

    local touch_x = screen_x * 4 / 9
    local touch_y = screen_y * 4 / 9
    local function touchBox(x, y)
        local box = shapes.newPolygonShape(0, 0, touch_x, 0, touch_x, touch_y, 0, touch_y)
        box:moveTo(x + touch_x / 2, y + touch_y / 2) -- 0, 0 is center
        return box
    end

    local display_offset = radius * 2;

    local width = math.max(1, math.floor(radius / 32))
    local arc = Arc:new({x = -radius, y = -radius, radius = radius, dot_radius = radius / 8, width = width})

    local map_radius = math.min(screen_x, screen_y) / 2.05 -- Fit onscreen
    local map_width = width * 1.5
    self.map = Arc:new({x = map_x, y = map_y, radius = map_radius, dot_radius = arc.dot_radius * 1.5, width = map_width})

    -- TODO don't duplicate end_rads start position here.
    self.players[1] = Player:new({
        control = Control:new({ key = 'q', region = touchBox(0, 0) }),
        status = self.status_tmpl:new({ display_x = display_offset, display_y = display_offset }),
        active = arc:new({player = 1, end_rads = math.pi * 5 / 4})
    })
    self.players[2] = Player:new({
        control = Control:new({ key = 'p', region = touchBox(screen_x - touch_x, 0) }),
        status = self.status_tmpl:new({ display_x = screen_x - display_offset, display_y = display_offset }),
        active = arc:new({player = 2, end_rads = math.pi * 7 / 4})
    })
    self.players[3] = Player:new({
        control = Control:new({ key = '.', region = touchBox(screen_x - touch_x, screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_x = screen_x - display_offset, display_y = screen_y - display_offset }),
        active = arc:new({player = 3, end_rads = math.pi * 1 / 4})
    })
    self.players[4] = Player:new({
        control = Control:new({ key = 'z', region = touchBox(0, screen_y - touch_y) }),
        status = self.status_tmpl:new({ display_x = display_offset, display_y = screen_y - display_offset }),
        active = arc:new({player = 4, end_rads = math.pi * 3 / 4})
    })

    Gamestate.switch(self.states.intermission)
end

return init
