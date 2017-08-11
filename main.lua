require 'player'

function love.load()
    -- cx = love.graphics.getWidth() / 2
	-- cy = love.graphics.getHeight() / 2

    love.physics.setMeter(1)
	World = love.physics.newWorld()
    E = love.physics.newEdgeShape(0, 0, 100, 100)
    Body = love.physics.newBody(World, 0, 0, "static")
    love.physics.newFixture(Body, E)

    Players = {}
    Players[1] = Player:new()
end

function love.update(dt)
    Players[1]:update(dt)
end

function love.keypressed(key, scan_code, is_repeat)
   Players[1]:changeDirection()
end

function love.draw()
    arc = Players[1].active
    love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.start_rads, arc.end_rads)
    trail = Players[1].trail
    for i = 1, #trail do
        arc = trail[i]
        love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.start_rads, arc.end_rads)
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