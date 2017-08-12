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

function Arc:normalize()
    while self.start_rads < 0 do
        self.start_rads = self.start_rads + 2 * math.pi
    end
    while self.start_rads >= 2 * math.pi do
        self.start_rads = self.start_rads - 2 * math.pi
    end
    while self.end_rads < 0 do
        self.end_rads = self.end_rads + 2 * math.pi
    end
    while self.end_rads >= 2 * math.pi do
        self.end_rads = self.end_rads - 2 * math.pi
    end
end

function Arc:changeDirection()
    dx = math.cos(self.end_rads) * self.radius * 2
    dy = math.sin(self.end_rads) * self.radius * 2
    start_rads = self.end_rads + math.pi
    new_arc = self:new({
        x = self.x + dx,
        y = self.y + dy,
        start_rads = start_rads,
        end_rads = start_rads,
        direction = self.direction == 'left' and 'right' or 'left'
    })
    new_arc:normalize()
    return new_arc
end

function Arc:addToCollider(collider)
    co = collider:circle(self.x, self.y, self.radius)
    co.arc = self
    -- Hard reference to collider object needed to stop GC
    self.co = co
end

function Arc:addContactLine(intersections)
    -- convert intersections to radians on arc
    -- define good/bad range
    self.contacts[#self.contacts+1] = {
    }
end

test = 0

function Arc:intersectsArc(other)
    -- test = test + 1
    -- test = test % 120
    -- if test > 0 then
    --     return
    -- end
    print('current angles')
    print(self.start_rads)
    print(self.end_rads)
    for i, angle in pairs(intersectAngles(self, other)) do
        end_rads_norm = self.end_rads - self.start_rads
        end_rads_norm = end_rads_norm >= 0 and end_rads_norm or end_rads_norm + 2 * math.pi
        print('intersect angle')
        print(angle)
        angle = angle - self.start_rads
        angle = angle >= 0 and angle or angle + 2 * math.pi
        print(end_rads_norm)
        print(angle)
        if angle < end_rads_norm then
            print('is intersect')
            gameIsPaused = true
        end
    end
end

function Arc:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
