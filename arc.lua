require 'circle'

debug = false

Arc = {
    x = 0,
    y = 0,
    radius = 0,
    width = 1,
    dot_radius = 0,
    start_rads = 0,
    end_rads = 0,
    total_rads = 0,
    direction = 'cw',
    player = 0,
    co = nil
}

function Arc:update(dr)
    self.total_rads = self.total_rads + dr
    self.end_rads = self.end_rads + (self.direction == 'acw' and -dr or dr)
end

function Arc:changeDirection()
    dx = math.cos(self.end_rads) * self.radius * 2
    dy = math.sin(self.end_rads) * self.radius * 2
    start_rads = self.end_rads + (self.direction == 'acw' and math.pi or -math.pi)
    new_arc = Arc:new({
        x = self.x + dx,
        y = self.y + dy,
        radius = self.radius,
        width = self.width,
        dot_radius = self.dot_radius,
        start_rads = start_rads,
        end_rads = start_rads,
        total_rads = self.total_rads,
        direction = self.direction == 'acw' and 'cw' or 'acw',
        player = self.player
    })
    return new_arc
end

function Arc:addToCollider(collider)
    local co = collider:circle(self.x, self.y, self.radius)
    co.arc = self
    -- Hard reference to collider object needed to stop GC
    self.co = co
end

function Arc:rads()
    return self.direction == 'acw' and self.end_rads or self.end_rads - math.pi
end

-- Return new arc with the portion before 'total_rads' is reached trimmed.
-- Return nil if this leaves no arc.
-- Used in collision detection to avoid immediate "collision" with previous path segment.
function Arc:withTrimmedStart(total_rads)
    local arc_delta = self.end_rads - self.start_rads
    local start_rads_adj = total_rads - self.total_rads
    if start_rads_adj > math.abs(arc_delta) then
        return nil
    elseif start_rads_adj <= 0 then
        return self
    end
    local start_rads = self.start_rads + start_rads_adj * math.sign(arc_delta)
    return self:new({ start_rads = start_rads })
end

function Arc:intersectsSelf()
    local arc_delta = self.end_rads - self.start_rads
    return math.abs(arc_delta) >= math.pi * 2
end

function Arc:intersectsArc(other)
    local intersect_angles = intersectAngles(self, other)
    if intersect_angles == nil then
        -- overlapping (should not happen)
        if isBetween(other.start_rads, other.end_rads, self.end_rads) then
            if debug then
                print('overlap found!')
            end
            return 1
        else
            return 0
        end
    else
        local intersects = 0;
        for i, angles in pairs(intersect_angles) do
            if debug then
                print('testing arcs')
                print('[' .. self.player .. ',' .. self.x .. ',' .. self.y .. ',' .. self.radius .. ']' .. ' ' .. self.start_rads .. ' : ' .. self.end_rads .. ' @' .. angles[2])
                print('[' .. other.player .. ',' .. other.x .. ',' .. other.y .. ',' .. other.radius .. ']' .. ' ' .. other.start_rads .. ' : ' .. other.end_rads .. ' @' .. angles[1])
            end
            if isBetween(self.start_rads, self.end_rads, angles[1]) and isBetween(other.start_rads, other.end_rads, angles[2]) then
                if debug then
                    print('intersect found!')
                end
                intersects = intersects + 1
            end
        end
        return intersects
    end
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

function Arc:drawArc(trail_color)
    love.graphics.setColor(trail_color[1], trail_color[2], trail_color[3], trail_color[4])
    love.graphics.setLineWidth(self.width)
    love.graphics.arc('line', 'open', self.x, self.y, self.radius, self.start_rads, self.end_rads)
end

function Arc:drawEnd(trail_length_font, trail_color, size, trail_length)
    love.graphics.setColor(trail_color[1], trail_color[2], trail_color[3], trail_color[4])
    local point = self:endPos()
    love.graphics.circle('fill', point.x, point.y, self.dot_radius * size)
    love.graphics.circle('line', point.x, point.y, self.dot_radius * size)

    love.graphics.setFont(trail_length_font)
    love.graphics.translate(point.x, point.y)
    love.graphics.rotate(self.end_rads)
    trail_length_str = string.format('%.2f', trail_length)
    local font_height = trail_length_font:getHeight()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print(trail_length_str, font_height / 1.5, -font_height / 2.4)
    love.graphics.origin()
end

function Arc:endPos()
    local x = self.x + math.cos(self.end_rads) * self.radius
    local y = self.y + math.sin(self.end_rads) * self.radius
    return { x = x, y = y }
end

function Arc:length()
    return math.abs(self.end_rads - self.start_rads)
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
