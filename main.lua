require 'player'
require 'scratch'

HC = require 'hc'

function love.load()
    scratch()
    width, height, flags = love.window.getMode()
	radius = height / 16

    collider = HC.new(100)

    -- top = collider:rectangle(-radius * 3, 200, width + radius * 3, 300)

    players = {}
    players[1] = Player:new(
        {
            active = Arc:new(
                {
                    x = 200,
                    y = 200,
                    radius = radius,
                    contacts = {}
                }
            )
        }
    )
    -- players[2] = Player:new(
    --     {
    --         active = Arc:new(
    --             {
    --                 x = 600,
    --                 y = 200,
    --                 radius = radius,
    --                 start_rads = 0,
    --                 end_rads = 0,
    --                 contacts = {}
    --             }
    --         )
    --     }
    -- )
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
    -- love.graphics.print(#players[2].active.contacts)
    -- top.draw('fill')
end
