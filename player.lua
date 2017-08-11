require 'arc'

Player = {
    active = Arc:new(),
    trail = {
    }
}

function Player:update(dt)
    self.active:update(dt)
end

function Player:changeDirection()
    self.trail[#self.trail+1]=self.active:snapshot()
    self.active:changeDirection()
end

function Player:new (o)
    o = o or { active = Arc:new({ x = 200, y = 200, radius = 32, start_rads = 0, end_rads = 0 }) }
    setmetatable(o, self)
    self.__index = self
    return o
end

