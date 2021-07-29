local vector = require 'hump.vector'

Status = {
    display_v = vector(0, 0),
    display_angle = 0,
    font = nil,
    line_width = 0,
    radius = 0,
    win_score = 12,

    playing = false,
    score = 0,
    trail_length_best = 0,
    trail_length_current = 0,
    trail_length_total = 0,
}

function Status:draw(color)
    local radius = self.radius
    love.graphics.translate(self.display_v.x, self.display_v.y)
    love.graphics.rotate(self.display_angle)
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    love.graphics.setLineWidth(self.line_width)
    local end_angle = math.pi + (math.pi * (self.score / self.win_score))
    love.graphics.arc('line', 'open', 0, 0, radius, 0, end_angle)

    love.graphics.setFont(self.font)
    local printf_left, printf_width = - radius, 2 * radius
    local font_vertical_offset = radius / 3
    local font_height_offset = - self.font:getHeight() / 2
    local trail_length_best = math.max(self.trail_length_best, self.trail_length_current)
    love.graphics.printf(string.format('%.2f', trail_length_best), printf_left, font_height_offset - font_vertical_offset, printf_width, 'center')
    local trail_length_total = self.trail_length_total + self.trail_length_current
    love.graphics.printf(string.format('%.1f', trail_length_total), printf_left, font_height_offset + font_vertical_offset, printf_width, 'center')

    love.graphics.origin()
end

function Status:updateCurrentTrail(trail_length)
    self.trail_length_current = trail_length
end

-- Called at end of intermission state.
function Status:finishedGame(score_delta)
    self.score = self.score + score_delta
    self.trail_length_best = math.max(self.trail_length_best, self.trail_length_current)
    self.trail_length_total = self.trail_length_total + self.trail_length_current
    self.trail_length_current = 0
end

function Status:hasWon()
    return self.score >= self.win_score
end

function Status:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
