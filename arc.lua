require 'circle'

debug = false

Arc = {
    x = 0,
    y = 0,
    radius = 0,
    start_rads = 0,
    end_rads = 0,
    total_rads = 0,
    direction = 'acw',
    player = 0
}

function Arc:update(dt)
    local delta = dt * 2
    self.total_rads = self.total_rads + delta
    self.end_rads = self.end_rads + (self.direction == 'acw' and delta or -delta)
end

function Arc:changeDirection()
    dx = math.cos(self.end_rads) * self.radius * 2
    dy = math.sin(self.end_rads) * self.radius * 2
    start_rads = self.end_rads + (self.direction == 'acw' and math.pi or -math.pi)
    new_arc = Arc:new({
        x = self.x + dx,
        y = self.y + dy,
        radius = self.radius,
        start_rads = start_rads,
        end_rads = start_rads,
        total_rads = self.total_rads,
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
    local arc_delta = self.end_rads - self.start_rads
    if self == other then
        return math.abs(arc_delta) > math.pi * 2
    end
    intersect_angles = intersectAngles(self, other)
    if intersect_angles == nil then
        -- overlapping (should not happen)
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
                print('[' .. self.player .. ',' .. self.x .. ',' .. self.y .. ',' .. self.radius .. ']' .. ' ' .. self.start_rads .. ' : ' .. self.end_rads .. ' @' .. angles[2])
                print('[' .. other.x .. ',' .. other.y .. ',' .. other.radius .. ']' .. ' ' .. other.start_rads .. ' : ' .. other.end_rads .. ' @' .. angles[1])
            end
            local start_rads = self.start_rads
            if self.player == other.player then
                local start_rads_adj = other.total_rads + (math.pi * 2) - self.total_rads
                if debug then
                    print('own trail adj')
                    print('[' .. self.total_rads .. ',' .. other.total_rads .. ',' .. start_rads_adj .. ',' .. arc_delta .. ']')
                end
                if start_rads_adj > math.abs(arc_delta) then
                    -- Haven't travelled far enough to hit own trail yet.
                    return false
                end
                if start_rads_adj > 0 then
                    start_rads = start_rads + start_rads_adj * math.sign(arc_delta)
                end
            end
            if isBetween(start_rads, self.end_rads, angles[1]) and isBetween(other.start_rads, other.end_rads, angles[2]) then
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

function Arc:drawEndDot()
    love.graphics.circle('fill', self.x + math.cos(self.end_rads) * self.radius, self.y + math.sin(self.end_rads) * self.radius, self.radius / 10)
end

function Arc:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function math.sign(n)
    return n > 0 and 1 or n < 0 and -1 or 0
end
