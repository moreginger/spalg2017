Status = {
    wins = 0,
    display_x = 0,
    display_y = 0,
    font = nil
}

function Status:draw(angle)
    love.graphics.setFont(self.font)
    love.graphics.printf(self.wins, self.display_x, self.display_y, 100, 'center', angle, 1, 1, 50, 10)
end

function Status:addWin()
    self.wins = self.wins + 1
end

function Status:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
