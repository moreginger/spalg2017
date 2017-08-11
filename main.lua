require 'player'

function love.load()
    -- cx = love.graphics.getWidth() / 2
	-- cy = love.graphics.getHeight() / 2

    love.physics.setMeter(1)
	World = love.physics.newWorld()
    E = love.physics.newEdgeShape(0, 0, 100, 100)
    Body = love.physics.newBody(World, 0, 0, "static")
    love.physics.newFixture(Body, E)

    players = {}
    players[1] = Player:new({ active = Arc:new({ x = 200, y = 200, radius = 32, start_rads = 0, end_rads = 0 }) })
    players[2] = Player:new({active = Arc:new({ x = 600, y = 200, radius = 32, start_rads = 0, end_rads = 0, direction = 'right' }) })
end

function love.update(dt)
    for i = 1, #players do
       players[i]:update(dt)
    end
end

function love.keypressed(key, scan_code, is_repeat)
   if key == 'a' then
       players[1]:changeDirection()
   elseif key == 'l' then
       players[2]:changeDirection()
   end
end

function love.draw()
    for i = 1, #players do
       players[i]:draw()
    end
    -- love.graphics.line(Body:getWorldPoints(E:getPoints()))
    -- World:rayCast(0, 100, 100, 0, worldRayCastCallback)
end

function worldRayCastCallback(fixture, x, y, xn, yn, fraction)
	local hit = {}
	hit.fixture = fixture
	hit.x, hit.y = x, y
	hit.xn, hit.yn = xn, yn
	hit.fraction = fraction
    
    love.graphics.line(hit.x, hit.y, hit.x + hit.xn * 25, hit.y + hit.yn * 25)
    love.graphics.print(x, 400, 300)
    
	return 1 -- Continues with ray cast through all shapes.
end