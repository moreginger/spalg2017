require 'test'

require 'arc'
require 'control'
require 'player'
require 'status'

HC = require 'hc'
shapes = require 'hc.shapes'

function love.load()
    test()

    screen_x, screen_y, flags = love.window.getMode()
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
    local arc = Arc:new({radius = radius})

    players = {}
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
    _reset()
end

function love.keypressed(key, scan_code, is_repeat)
    for i = 1, #players do
       players[i]:keypressed(key, collider)
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    for i = 1, #players do
       players[i]:touchpressed(x, y, collider)
    end
end

function love.focus(f)
    gameIsPaused = not f
end

function love.update(dt)
    if gameIsPaused then return end
    active = 0
    for i = 1, #players do
        if players[i].alive then
            active = active + 1
            players[i]:update(dt, collider)
            players[i]:detectCollision(collider)
        end
    end
    if active <= 1 then
        for i = 1, #players do
            if players[i].alive then
                players[i]:won()
            end
        end
        _reset()
    end
end

function love.draw()
    for i = 1, #players do
       players[i]:draw()
    end
    map:draw()
end

function _reset()
    collider = HC.new(100)
    map_radius = math.min(screen_x, screen_y) / 2
    map_x = screen_x / 2
    map_y = screen_y / 2
    map = Arc:new({ x = map_x, y = map_y, radius = map_radius, end_rads = math.pi * 2, direction = 'acw', player = 0 })
    map:addToCollider(collider)

    for i = 1, #players do
        players[i].alive = true
        players[i].trail = {}
    end

    local function _resetActive(player, angle)
        player.active = Arc:new({ x = map_x + math.cos(angle) * map_radius * 3 / 4, y = map_y + math.sin(angle) * map_radius * 3 / 4, radius = player.active.radius, start_rads = angle, end_rads = angle, direction = 'acw', player = player.active.player })
    end
    _resetActive(players[1], math.pi * 5 / 4)
    _resetActive(players[2], math.pi * 7 / 4)
    _resetActive(players[3], math.pi * 1 / 4)
    _resetActive(players[4], math.pi * 3 / 4)

    for i = 1, #players do
        players[i]:addToCollider(collider)
    end
end
