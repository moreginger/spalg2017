require 'arc'

Player = {
    active = nil,
    trail = nil,
    alive = true,
    status = nil
}

function Player:update(dt)
    self.active:update(dt)
    if math.abs(self.active.start_rads - self.active.end_rads) > math.pi / 2 then
        -- Split arc to stop self-collisions with previous arc segment, working together with angle restrition in detectCollision.
        self.trail[#self.trail+1] = self.active
        self.active = self.active:new({start_rads = self.active.end_rads})
        self:addToCollider(collider)
    end
end

function Player:detectCollision(collider)
    for shape, delta in pairs(collider:collisions(self.active.co)) do
        if self.active.player == shape.arc.player and math.abs(self.active:rads() - shape.arc:rads()) <= math.pi then
            -- Impossible to collide with own line if < half circle direction change
            -- Needed to stop insta-collisions on direction change
        elseif self.active:intersectsArc(shape.arc) then
            self.alive = false
        end
    end
end

function Player:changeDirection(collider)
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

