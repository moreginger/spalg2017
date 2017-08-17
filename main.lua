require 'test'

require 'arc'
require 'player'

HC = require 'hc'

function love.load()
    test()

    players = {}
    players[1] = Player:new()
    players[2] = Player:new()
    _reset()
end

function love.keypressed(key, scan_code, is_repeat)
   if key == 'a' then
       players[1]:changeDirection(collider)
   elseif key == 'l' then
       players[2]:changeDirection(collider)
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
    width, height, flags = love.window.getMode()
	radius = height / 16

    collider = HC.new(100)
    map_radius = math.min(width, height) / 2
    map_x = width / 2
    map_y = height / 2
    map = Arc:new({ x = map_x, y = map_y, radius = map_radius, end_rads = math.pi * 2, direction = 'acw', player = 0 })
    map:addToCollider(collider)

    for i = 1, #players do
        players[i].alive = true
        players[i].trail = {}
    end
    players[1].active = Arc:new({ x = map_x + math.cos(math.pi) * map_radius / 2, y = map_y + math.cos(math.pi) * map_radius / 2, radius = radius, start_rads = 0, end_rads = 0, player = 1})
    players[2].active = Arc:new({ x = map_x + math.cos(0) * map_radius / 2, y = map_y + math.cos(0) * map_radius / 2, radius = radius, start_rads = math.pi, end_rads = math.pi, player = 2})

    for i = 1, #players do
        players[i]:addToCollider(collider)
        print('p' .. i .. ':' .. players[i].wins)
    end
end