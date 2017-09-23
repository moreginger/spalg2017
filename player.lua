require 'arc'

Player = {
    active = nil,
    trail = nil,
    alive = true,
    status = nil,
    control = nil
}

function Player:update(dt)
    self.active:update(dt)
end

function Player:detectCollision(collider)
    for shape, delta in pairs(collider:collisions(self.active.co)) do
        if self.active:intersectsArc(shape.arc) then
            self.alive = false
        end
    end
    if self.active:intersectsArc(self.active) then
      self.alive = false
    end
end

function Player:keypressed(key, collider)
    if self.control:isChangeDirectionKey(key) then
        self:_changeDirection(collider)
    end
end

function Player:touchpressed(x, y, collider)
    if self.control:isChangeDirectionTouch(x, y) then
        self:_changeDirection(collider)
    end
end

function Player:_changeDirection(collider)
    self.trail[#self.trail+1] = self.active
    self.active = self.active:changeDirection()
    self:addToCollider(collider)
end

function Player:addToCollider(collider)
    self.active:addToCollider(collider)
end

function Player:draw()
    -- Active arc
    local active = self.active
    active:draw()
    if self.alive then
        active:drawEndDot()
    end
    -- Trail
    for i = 1, #self.trail do
        self.trail[i]:draw()
    end
    -- Status
    self.status:draw(self.active:rads() + math.pi)
end

function Player:won()
    self.status:addWin()
end

function Player:reset(arc)
    self.active = arc
    self.trail = {}
    self.alive = true
end

function Player:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

