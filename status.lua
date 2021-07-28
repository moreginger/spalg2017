local vector = require 'hump.vector'

Status = {
    display_v = vector(0, 0),
    display_angle = 0,
    line_width = 0,
    radius = 0,

    playing = false,
    score = 0,
    win_score = 12,
    trail_color = { 0, 1, 0, 1 },
}

function Status:draw()
    love.graphics.translate(self.display_v.x, self.display_v.y)
    love.graphics.rotate(self.display_angle)
    local trail_color = self.trail_color
    love.graphics.setColor(trail_color[1], trail_color[2], trail_color[3], trail_color[4])
    love.graphics.setLineWidth(self.line_width)
    local end_angle = math.pi + (math.pi * (self.score / self.win_score))
    love.graphics.arc('line', 'open', 0, 0, self.radius, 0, end_angle)

    love.graphics.origin()
end

-- Called at end of intermission state.
function Status:updateScore(delta)
    self.score = self.score + delta
    return self.score >= self.win_score
end

function Status:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
