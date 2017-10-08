package.path = "../?.lua;" .. package.path

local Gamestate = require 'hump.gamestate'

local shapes = require 'hc.shapes'

require 'arc'
require 'control'
require 'player'
require 'status'

local intermission = require 'states.intermission'

-- (re)initialize game state
local init = {
    env = {
        dt_speedup = 1,
        round = 0
    },
    map = nil,
    players = {}
}

function init:enter()
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

    local arc = Arc:new({radius = radius, dot_radius = radius / 8})

    local map_radius = math.min(screen_x, screen_y) / 2.1 -- Fit onscreen
    self.map = Arc:new({x = map_x, y = map_y, radius = map_radius, dot_radius = radius / 8})

    local players = self.players
    players[1] = Player:new({
        control = Control:new({ key = 'q', region = touchBox(0, 0) }),
        status = status:new({ display_x = display_offset, display_y = display_offset }),
        active = arc:new({player = 1})
    })
    players[2] = Player:new({
        control = Control:new({ key = 'p', region = touchBox(screen_x - touch_x, 0) }),
        status = status:new({ display_x = screen_x - display_offset, display_y = display_offset }),
        active = arc:new({player = 2})
    })
    players[3] = Player:new({
        control = Control:new({ key = '.', region = touchBox(screen_x - touch_x, screen_y - touch_y) }),
        status = status:new({ display_x = screen_x - display_offset, display_y = screen_y - display_offset }),
        active = arc:new({player = 3}) }
    )
    players[4] = Player:new({
        control = Control:new({ key = 'z', region = touchBox(0, screen_y - touch_y) }),
        status = status:new({ display_x = display_offset, display_y = screen_y - display_offset }),
        active = arc:new({player = 4})
    })

    Gamestate.switch(intermission)
end

return init
