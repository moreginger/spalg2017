require 'test'

require 'arc'
require 'player'
require 'status'

HC = require 'hc'

function love.load()
    test()

    screen_x, screen_y, flags = love.window.getMode()
	local radius = math.min(screen_x, screen_y) / 16

    local status_font = love.graphics.newFont('resources/Taurus-Mono-Outline-Regular.otf', radius)
    players = {}
    local arc = Arc:new({radius = radius})
    players[1] = Player:new({ status = Status:new({ display_x = 50, display_y = 50, font = status_font}), active = arc:new({player = 1}) })
    players[2] = Player:new({ status = Status:new({ display_x = screen_x - 50, display_y = 50, font = status_font}), active = arc:new({player = 2}) })
    players[3] = Player:new({ status = Status:new({ display_x = screen_x - 50, display_y = screen_y - 50, font = status_font}), active = arc:new({player = 3}) })
    players[4] = Player:new({ status = Status:new({ display_x = 50, display_y = screen_y - 50, font = status_font}), active = arc:new({player = 4}) })
    _reset()
end

function love.keypressed(key, scan_code, is_repeat)
   if key == 'q' then
       players[1]:changeDirection(collider)
   elseif key == 'p' then
       players[2]:changeDirection(collider)
    elseif key == '.' then
       players[3]:changeDirection(collider)
    elseif key == 'z' then
       players[4]:changeDirection(collider)
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
        player.active = player.active:new({ x = map_x + math.cos(angle) * map_radius * 3 / 4, y = map_y + math.sin(angle) * map_radius * 3 / 4, start_rads = angle, end_rads = angle, direction = 'acw' })
    end
    _resetActive(players[1], math.pi * 5 / 4)
    _resetActive(players[2], math.pi * 7 / 4)
    _resetActive(players[3], math.pi * 1 / 4)
    _resetActive(players[4], math.pi * 3 / 4)

    for i = 1, #players do
        players[i]:addToCollider(collider)
    end
end
