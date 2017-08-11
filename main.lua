require 'player'

function love.load()
    cx = love.graphics.getWidth()/2
	cy = love.graphics.getHeight()/2

    love.physics.setMeter(1)
	World = love.physics.newWorld()
    E = love.physics.newEdgeShape(0, 0, 100, 100)
    Body = love.physics.newBody(World, 0, 0, "static")
    love.physics.newFixture(Body, E)

    Players = {}
    Players[0] = Player:new({ arc = { x = 100, y = 100, radius = 50, start_rads = 0, end_rads = 0 }})
end

function love.update(dt)
    Players[0]:update(dt)
end

function love.keypressed(key, scan_code, is_repeat)
   Players[0]:changeDirection()
end

function love.draw()
    arc = Players[0].arc
    love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.start_rads, arc.end_rads)
    
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