require 'test'

require 'arc'
require 'player'

HC = require 'hc'

function love.load()
    test()

    width, height, flags = love.window.getMode()
	radius = height / 16

    collider = HC.new(100)
    map_radius = math.min(width, height) / 2
    map = Arc:new({ x = width / 2, y = height / 2, radius = map_radius, end_rads = math.pi * 2, direction = 'acw', player = 0 })
    map:addToCollider(collider)

    players = {}
    players[1] = Player:new(
        {
            active = Arc:new(
                {
                    x = 200,
                    y = 200,
                    radius = radius,
                    player = 1
                }
            )
        }
    )
    players[2] = Player:new(
        {
            active = Arc:new(
                {
                    x = 600,
                    y = 200,
                    radius = radius,
                    player = 2
                }
            )
        }
    )
    for i = 1, #players do
        players[i]:addToCollider(collider)
    end
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
    for i = 1, #players do
       players[i]:update(dt, collider)
       players[i]:detectCollision(collider)
    end
end

function love.draw()
    for i = 1, #players do
       players[i]:draw()
    end
end
