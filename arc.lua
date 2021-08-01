require 'circle'

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

function Arc:intersectsSelf()
    local arc_delta = self.end_rads - self.start_rads
    return math.abs(arc_delta) >= math.pi * 2
end

function Arc:intersectsArc(other)
    -- Special case self intersect
    if self == other then
        return (math.abs(self.end_rads - self.start_rads) >= 2 * math.pi) and 1 or 0
    end

    local intersect_angles = intersectAngles(self, other)
    if intersect_angles == nil then
        -- overlapping (should not happen)
        return getAdjustedBetween(other.start_rads, other.end_rads, self.end_rads) and 1 or 0
    else
        local intersects = 0;
        for i, angles in pairs(intersect_angles) do
            local self_intersect, other_intersect = getAdjustedBetween(self.start_rads, self.end_rads, angles[1]), getAdjustedBetween(other.start_rads, other.end_rads, angles[2])
            if self_intersect and other_intersect then
                if self.player ~= other.player then
                    intersects = intersects + 1
                else
                    -- Can't hit own line until at least 2 * pi past intersection. This stops adjoining arc segments from intersecting until a full circle is complete.
                    local other_total_at_intersect = other:totalWithEnd(other_intersect)
                    if self.total_rads - other_total_at_intersect >= 2 * math.pi then
                        intersects = intersects + 1
                    end
                end
            end
        end
        return intersects
    end
end

function getAdjustedBetween(start_rads, end_rads, query_rads)
    start_rads, end_rads = math.min(start_rads, end_rads), math.max(start_rads, end_rads)
    local two_pi = 2 * math.pi
    -- Adjust query which is in 0..2*pi range to the (possible) range of our arc.
    query_rads = query_rads + two_pi * math.floor(start_rads / two_pi)
    query_rads = (start_rads <= query_rads) and query_rads or query_rads + two_pi
    return (start_rads <= query_rads and query_rads <= end_rads) and query_rads or nil
end

function Arc:totalWithEnd(new_end)
    local end_delta = self.end_rads - new_end
    return self.total_rads - math.abs(end_delta)
end

function Arc:drawArc(trail_color)
    love.graphics.setColor(trail_color[1], trail_color[2], trail_color[3], trail_color[4])
    love.graphics.setLineWidth(self.width)

    local length = math.abs(self.start_rads - self.end_rads) * self.radius
    if length >= 5 then
        love.graphics.arc('line', 'open', self.x, self.y, self.radius, self.start_rads, self.end_rads)
    else
        -- love.graphics.arc doesn't draw anything for very small arcs
        love.graphics.line(self.x + self.radius * math.cos(self.start_rads), self.y + self.radius * math.sin(self.start_rads), self.x + self.radius * math.cos(self.end_rads), self.y + self.radius * math.sin(self.end_rads))
    end
end

function Arc:drawEnd(trail_length_font, trail_color, size, trail_length)
    love.graphics.setColor(trail_color[1], trail_color[2], trail_color[3], trail_color[4])
    local point = self:endPos()
    love.graphics.circle('fill', point.x, point.y, self.dot_radius * size)
    love.graphics.circle('line', point.x, point.y, self.dot_radius * size)

    love.graphics.setFont(trail_length_font)
    love.graphics.translate(point.x, point.y)
    love.graphics.rotate(self.end_rads)
    local font_height = trail_length_font:getHeight()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print(string.format('%.2f', trail_length), font_height / 1.5, -font_height / 2.4)
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

function Arc:toJson()
    return {
        direction = self.direction,
        end_rads = self.end_rads,
        radius = self.radius,
        start_rads = self.start_rads,
        total_rads = self.total_rads,
        x = self.x,
        y = self.y,
    }
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
