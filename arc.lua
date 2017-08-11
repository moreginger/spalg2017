require 'circle'

Arc = {
    x = 0,
    y = 0,
    radius = 0,
    start_rads = 0,
    end_rads = 0,
    direction = 'left'
}

function Arc:update(dt)
    self.end_rads = self.end_rads + (self.direction == 'left' and -dt or dt) * 1
end

function Arc:changeDirection()
    dx = math.cos(self.end_rads) * self.radius * 2
    dy = math.sin(self.end_rads) * self.radius * 2
    self.x = self.x + dx
    self.y = self.y + dy
    self.start_rads = self.direction == 'left' and self.end_rads + math.pi or self.end_rads - math.pi
    self.end_rads = self.start_rads
    self.contacts = {}
    self.direction = self.direction == 'left' and 'right' or 'left'
end

function Arc:addToCollider(collider)
    co_arc = collider:circle(self.x, self.y, self.radius)
    co_arc.arc = self:snapshot()
    return co_arc
end

function Arc:addContactLine(intersections)
    -- convert intersections to radians on arc
    -- define good/bad range
    self.contacts[#self.contacts+1] = {
    }
end

test = 0

function Arc:intersectsArc(other)
    test = test + 1
    test = test % 120
    if test > 0 then
        return
    end
    print('current angles')
    print(self.start_rads)
    print(self.end_rads)
    for i, angle in pairs(intersectAngles(self, other)) do
        end_rads_norm = self.end_rads - self.start_rads
        end_rads_norm = end_rads_norm >= 0 and end_rads_norm or end_rads_norm + math.pi * 2
        print('intersect angle')
        print(angle)
        angle = angle - self.start_rads
        angle = angle >= 0 and angle or angle + math.pi * 2
        if angle < end_rads_norm then
            print('is intersect')
        end
    end
end

function Arc:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Arc:snapshot()
   return { x = self.x, y = self.y, radius = self.radius, start_rads = self.start_rads, end_rads = self.end_rads }
end
