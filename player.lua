require 'arc'

Player = {
    start_rads = 0,
    active = nil,
    toggle_time = nil, -- Time since last direction change, or nil if none.
    trail = {},
    alive = true,
    status = nil,
    control = nil
}

function Player:update(dr)
    self.active:update(dr)
    self.status:update(dr, self.active.end_rads)
    if self.toggle_time ~= nil then
        self.toggle_time = self.toggle_time + dr
    end
end

function Player:detectCollision(collider, dr)
    if self.active:intersectsSelf() then
      self.alive = false
    else
        for shape, delta in pairs(collider:collisions(self.active.co)) do
            local arc = self.active
            local other = shape.arc
            if arc.player == other.player then
                arc = arc:withTrimmedStart(other.total_rads + math.pi * 2)
            end
            if arc ~= nil then
                local intersects = arc:intersectsArc(other)
                if intersects > 0 then
                    -- OK arcs intersect but who hit who?
                    local regressedArc = arc:new()
                    regressedArc:update(-dr)
                    if intersects ~= regressedArc:intersectsArc(other) then
                        self.alive = false
                    end
                end
            end
        end
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
    self.toggle_time = 0
    self.status.playing = true
    self.trail[#self.trail+1] = self.active
    self.active = self.active:changeDirection()
    self:addToCollider(collider)
end

function Player:addToCollider(collider)
    self.active:addToCollider(collider)
end

function Player:draw()
    local active = self.active
    active:draw()
    if self.alive then
        active:drawEndDot(2 - (self.toggle_time ~= nil and math.min(1, self.toggle_time * 4) or 1))
    end
    for i = 1, #self.trail do
        self.trail[i]:draw()
    end
    self.status:draw(active.total_rads)
end

function Player:won()
    self.status:addWin()
    return self.status.wins
end

function Player:playing()
    return self.status.playing
end

function Player:reset(arc)
    self.active = arc
    self.toggle_time = nil
    self.status.playing = false
    self.trail = {}
    self.alive = true
end

function Player:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

