package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local HC = require 'hc'
local shapes = require 'hc.shapes'

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
    states = {}
}

function init:enter()
    -- States object to avoid cyclical deps.
    self.states.init = init
    self.states.intermission = intermission
    self.states.game = game
    self.states.fin = fin
    self.states.pause = pause

    local screen_x, screen_y, flags = love.window.getMode()
    local map_x = screen_x / 2
    local map_y = screen_y / 2
	local radius = math.min(screen_x, screen_y) / 16

    local touch_x = screen_x / 3
    local touch_y = screen_y / 3
    local function touchBox(x, y)
        local box = shapes.newPolygonShape(0, 0, touch_x, 0, touch_x, touch_y, 0, touch_y)
        box:moveTo(x + touch_x / 2, y + touch_y / 2) -- 0, 0 is center
        return box
    end

    local font_size = radius * 1.5
    local display_offset = radius * 2;
    local font = love.graphics.newFont('resources/Taurus-Mono-Outline-Regular.otf', font_size)
    local status = Status:new({ font = font, display_w = font_size * 3, display_h = font_size })

    local arc = Arc:new({x = -radius, y = -radius, radius = radius, dot_radius = radius / 8})

    local map_radius = math.min(screen_x, screen_y) / 2.05 -- Fit onscreen
    self.map = Arc:new({x = map_x, y = map_y, radius = map_radius, dot_radius = radius / 8})

    self.players[1] = Player:new({
        control = Control:new({ key = 'q', region = touchBox(0, 0) }),
        status = status:new({ display_x = display_offset, display_y = display_offset }),
        active = arc:new({player = 1})
    })
    self.players[2] = Player:new({
        control = Control:new({ key = 'p', region = touchBox(screen_x - touch_x, 0) }),
        status = status:new({ display_x = screen_x - display_offset, display_y = display_offset }),
        active = arc:new({player = 2})
    })
    self.players[3] = Player:new({
        control = Control:new({ key = '.', region = touchBox(screen_x - touch_x, screen_y - touch_y) }),
        status = status:new({ display_x = screen_x - display_offset, display_y = screen_y - display_offset }),
        active = arc:new({player = 3})
    })
    self.players[4] = Player:new({
        control = Control:new({ key = 'z', region = touchBox(0, screen_y - touch_y) }),
        status = status:new({ display_x = display_offset, display_y = screen_y - display_offset }),
        active = arc:new({player = 4})
    })

    Gamestate.switch(self.states.intermission)
end

return init
