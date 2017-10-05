Status = {
    wins = 0,
    display_x = 0,
    display_y = 0,
    display_w = 0,
    display_h = 0,
    font = nil
}

function Status:draw(angle)
    love.graphics.setFont(self.font)
    love.graphics.printf(self.wins, self.display_x, self.display_y, self.display_w, 'center', angle, 1, 1, self.display_w / 2, self.display_h  / 2)
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