require 'circle'

debug = false

Arc = {
    x = 0,
    y = 0,
    radius = 0,
    start_rads = 0,
    end_rads = 0,
    direction = 'acw',
    player = 0
}

function Arc:update(dt)
    self.end_rads = self.end_rads + (self.direction == 'acw' and dt * 2 or -dt * 2)
end

function Arc:changeDirection()
    dx = math.cos(self.end_rads) * self.radius * 2
    dy = math.sin(self.end_rads) * self.radius * 2
    start_rads = self.end_rads + (self.direction == 'acw' and math.pi or -math.pi)
    new_arc = self:new({
        x = self.x + dx,
        y = self.y + dy,
        start_rads = start_rads,
        end_rads = start_rads,
        direction = self.direction == 'acw' and 'cw' or 'acw',
        player = self.player
    })
    return new_arc
end

function Arc:addToCollider(collider)
    co = collider:circle(self.x, self.y, self.radius)
    co.arc = self
    -- Hard reference to collider object needed to stop GC
    self.co = co
end

function Arc:rads()
    return self.direction == 'acw' and self.end_rads or self.end_rads - math.pi
end

function Arc:intersectsArc(other)
    intersect_angles = intersectAngles(self, other)
    if intersect_angles == nil then
        -- overlapping (probably self)
        if isBetween(other.start_rads, other.end_rads, self.end_rads) then
            if debug then
                print('overlap found!')
            end
            return true
        end
    else
        for i, angles in pairs(intersect_angles) do
            if debug then
                print('testing arcs')
                print('[' .. self.x .. ',' .. self.y .. ',' .. self.radius .. ']' .. ' ' .. self.start_rads .. ' : ' .. self.end_rads .. ' @' .. angles[2])
                print('[' .. other.x .. ',' .. other.y .. ',' .. other.radius .. ']' .. ' ' .. other.start_rads .. ' : ' .. other.end_rads .. ' @' .. angles[1])
            end
            if isBetween(self.start_rads, self.end_rads, angles[1]) and isBetween(other.start_rads, other.end_rads, angles[2]) then
                if debug then
                    print('intersect found!')
                end
                return true
            end
        end
    end
    return false
end

function isBetween(start_rads, end_rads, query_rads)
    start_rads, end_rads = math.min(start_rads, end_rads), math.max(start_rads, end_rads)
    if debug then
        print('start end query')
        print(start_rads, end_rads, query_rads)
    end
    if end_rads - start_rads >= math.pi * 2 then return true end
    end_rads = normalizeAngle(end_rads - start_rads)
    query_rads = normalizeAngle(query_rads - start_rads)
    if debug then print('-', end_rads, query_rads) end
    return query_rads <= end_rads
end

function Arc:draw()
    love.graphics.arc('line', 'open', self.x, self.y, self.radius, self.start_rads, self.end_rads)
end

function Arc:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
