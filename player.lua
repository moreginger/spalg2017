Player = {
    arc = {
        x = 0,
        y = 0,
        radius = 0,
        start_rads = 0,
        end_rads = 0,
        direction = 'left'
    },
    trail = {
    }
}

function Player:update(dt)
    self.arc.end_rads = self.arc.end_rads + (self.arc.direction == 'left' and -dt or dt)
end

function Player:changeDirection()
    arc = self.arc
    dx = math.cos(arc.end_rads) * arc.radius * 2
    dy = math.sin(arc.end_rads) * arc.radius * 2
    arc.x = arc.x + dx
    arc.y = arc.y + dy
    arc.start_rads = arc.end_rads + math.pi
    arc.end_rads = arc.start_rads
    arc.direction = arc.direction == 'left' and 'right' or 'left'
end

function Player:new (o)
    o = o or {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

