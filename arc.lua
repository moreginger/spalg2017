Arc = {
    x = 0,
    y = 0,
    radius = 0,
    start_rads = 0,
    end_rads = 0,
    direction = 'left'
}

function Arc:update(dt)
    self.end_rads = self.end_rads + (self.direction == 'left' and -dt or dt) * 4
end

function Arc:changeDirection()
    dx = math.cos(self.end_rads) * self.radius * 2
    dy = math.sin(self.end_rads) * self.radius * 2
    self.x = self.x + dx
    self.y = self.y + dy
    self.start_rads = self.end_rads + math.pi
    self.end_rads = self.start_rads
    self.contacts = {}
    self.direction = self.direction == 'left' and 'right' or 'left'
end

function Arc:addToCollider(collider)
    co_arc = collider:circle(self.x, self.y, self.radius)
    co_arc.start_rads = self.start_rads
    co_arc.end_rads = self.end_rads
    return co_arc
end

function Arc:addContactLine(intersections)
    -- convert intersections to radians on arc
    -- define good/bad range
    self.contacts[#self.contacts+1] = {
    }
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
