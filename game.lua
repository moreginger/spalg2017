require 'test'

require 'arc'
require 'control'
require 'player'
require 'status'

HC = require 'hc'
shapes = require 'hc.shapes'

local game = {
  world = {
    dt_speedup = 1,
    round = 0,
    map = {
      alive = false
    }
  },
  players = {}
}

function game:load()
    -- test()

    screen_x, screen_y, flags = love.window.getMode()
    map_x = screen_x / 2
    map_y = screen_y / 2
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

    local map_radius = math.min(screen_x, screen_y) / 2.1
    self.world.map.arc = Arc:new({radius = map_radius, dot_radius = radius / 8})

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
    self:_resetMap()
    self:_resetPlayers()
end

function game:keypressed(key, scan_code, is_repeat)
    local players = self.players
    for i = 1, #players do
       players[i]:keypressed(key, collider)
    end
end

function game:touchpressed(id, x, y, dx, dy, pressure)
    local players = self.players
    for i = 1, #players do
       players[i]:touchpressed(x, y, collider)
    end
end

function game:focus(f)
    gameIsPaused = not f
end

function game:update(dt)
    if gameIsPaused then return end
    local world = self.world
    local players = self.players
    local dr = dt * self.world.dt_speedup
    if world.map.alive then
      world.map.arc:update(4 * dr)
      world.map.alive = not world.map.arc:intersectsSelf()
      if not world.map.alive then
        game:_resetPlayers()
      end
      return
    else
        active = 0
        for i = 1, #players do
            if players[i].alive then
                active = active + 1
                players[i]:update(dr)
                players[i]:detectCollision(collider, dr)
            end
        end
        if active <= 1 then
            for i = 1, #players do
                if players[i].alive then
                    players[i]:won()
                end
            end
            if active == 1 then
                world.dt_speedup = world.dt_speedup + 0.1
            end
            game:_resetMap()
        end
    end
end

function game:draw()
    local world = self.world
    local players = self.players
    for i = 1, #players do
       players[i]:draw()
    end
    world.map.arc:draw()
    if world.map.alive then
      world.map.arc:drawEndDot()
    end
end

function game:_resetMap()
    local world = self.world
    world.round = world.round + 1

    collider = HC.new(100)

    -- total_rads at least 2pi less than 0 so that lines will definitely collide :)
    local map_start_rads = (3 + world.round % 4 * 2) * math.pi / 4
    world.map.arc = Arc:new({ x = map_x, y = map_y, radius = world.map.arc.radius, dot_radius = world.map.arc.dot_radius, total_rads = -10, start_rads = map_start_rads, end_rads = map_start_rads, direction = 'cw', player = 0 })
    world.map.arc:addToCollider(collider)
    world.map.alive = true
end

function game:_resetPlayers()
    local players = self.players
    for i = 1, #players do
        players[i].alive = true
        players[i].trail = {}
    end

    local function _resetActive(player, angle)
        local r = self.world.map.arc.radius * 0.7
        player.active = Arc:new({ x = map_x + math.cos(angle) * r, y = map_y + math.sin(angle) * r, radius = player.active.radius, dot_radius = player.active.dot_radius, start_rads = angle, end_rads = angle, direction = 'cw', player = player.active.player })
    end
    _resetActive(players[1], math.pi * 5 / 4)
    _resetActive(players[2], math.pi * 7 / 4)
    _resetActive(players[3], math.pi * 1 / 4)
    _resetActive(players[4], math.pi * 3 / 4)

    for i = 1, #players do
        players[i]:addToCollider(collider)
    end
end

return game
