Status = {
    wins = 0,
    display_x = 0,
    display_y = 0,
    step = 0
}

function Status:draw(angle)
    love.graphics.translate(self.display_x, self.display_y)
    love.graphics.rotate(angle)
    love.graphics.setColor(150, 150, 150, 255)
    local length = 2.3
    local step = self.step
    -- TODO size by screen
    for i = -1.5, 1.5, 1 do
        love.graphics.line(i * step, -length * step, i * step, length * step)
        love.graphics.line(-length * step, i * step, length * step, i * step)
    end
    local wins = math.ceil(self.wins)

    love.graphics.setColor(255, 255, 255, 255)
    local r = math.floor(step / 3)
    for i = 1, wins, 1 do
        local x = (i - 1) % 5 - 2
        local y = math.ceil(i / 5) - 3
        love.graphics.circle('line', x * step, y * step, r)
    end

    love.graphics.origin()
end

function Status:addWin()
    self.wins = self.wins + 1
end

function Status:subWins(wins)
    self.wins = self.wins - wins
    self.wins = self.wins < 0 and 0 or self.wins
end

function Status:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
