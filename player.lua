require 'arc'

Player = {
    active = nil,
    toggle_time = nil, -- Time since last direction change, or nil if none.
    trail = {},
    alive = true,
    status = nil,
    control = nil
}

function Player:update(dr)
    self.active:update(dr)
    if self.toggle_time ~= nil then
        self.toggle_time = self.toggle_time + dr * 4
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
    self.trail[#self.trail+1] = self.active
    self.active = self.active:changeDirection()
    self:addToCollider(collider)
end

function Player:addToCollider(collider)
    self.active:addToCollider(collider)
end

function Player:draw(cfg)
    local active = self.active
    if cfg.trails then
        active:draw()
        if self.alive then
            active:drawEndDot(2 - (self.toggle_time ~= nil and math.min(1, self.toggle_time) or 1))
        end
    end
    if cfg.status then
        for i = 1, #self.trail do
            self.trail[i]:draw()
        end
        self.status:draw(active:rads() + math.pi)
    end
end

function Player:drawBloom()
    for i = 1, #self.trail do
        if not self.trail[i].isBloomed then
            self.trail[i].isBloomed = true
            self.trail[i]:draw()
        end
    end
end

function Player:won()
    self.status:addWin()
end

function Player:playing()
    return self.toggle_time ~= nil
end

function Player:reset(arc)
    self.active = arc
    self.toggle_time = nil
    self.trail = {}
    self.alive = true
end

function Player:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

