require 'arc'

Player = {
    active = Arc:new(),
    trail = {
    }
}

function Player:update(dt)
    self.active:update(dt)
    self.co_active.end_rads = self.active.end_rads
end

function Player:detectCollision(collider)
    for shape, delta in pairs(collider:collisions(self.co_active)) do
        print(shape)
    end
end

function Player:changeDirection(collider)
    snapshot = self.active:snapshot()
    -- nope
    snapshot.co = self.co_active
    self.trail[#self.trail+1] = snapshot
    self.active:changeDirection()
    self:addToCollider(collider)
end

function Player:addToCollider(collider)
    print('added')
    self.co_active = self.active:addToCollider(collider)
    -- todo hard refs to objects!!!
end

function Player:draw()
    arc = self.active
    love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.start_rads, arc.end_rads)
    for i = 1, #self.trail do
        arc = self.trail[i]
        love.graphics.arc('line', 'open', arc.x, arc.y, arc.radius, arc.start_rads, arc.end_rads)
    end
end

function Player:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

