require 'arc'

Player = {
    active = Arc:new(),
    trail = {
    }
}

function Player:update(dt)
    self.active:update(dt)
end

function exit()
   love.timer.sleep(600)
end

function Player:detectCollision(collider)
    for shape, delta in pairs(collider:collisions(self.active.co)) do
        if self.active.player == shape.arc.player and math.abs(self.active:rads() - shape.arc:rads()) <= math.pi then
            -- Impossible to collide with own line if < half circle direction change
            -- Needed to stop insta-collisions on direction change
        elseif self.active:intersectsArc(shape.arc) then
            exit()
        end
    end
end

function Player:changeDirection(collider)
    self.trail[#self.trail+1] = self.active
    self.active = self.active:changeDirection()
    self:addToCollider(collider)
end

function Player:addToCollider(collider)
    print('added')
    self.co_active = self.active:addToCollider(collider)
    print(self.active.start_rads)
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

