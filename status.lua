local tween = require 'tween.tween'
local vector = require 'hump.vector'

Status = {
    display_v = vector(0, 0),
    dot_size = 0,
    step_size = 0,

    playing = false,
    wins = 0,

    angle = 0,
    win_tween = nil
}

-- Only called during intermission to animate win.
function Status:update(dr, angle)
    self.angle = angle
    if self.win_tween ~= nil then
        self:_updateWinTweenTarget()
        self.win_tween:update(dr)
    end
end

function Status:draw(total_rads)
    love.graphics.translate(self.display_v.x, self.display_v.y)
    love.graphics.rotate(self.angle)
    local alpha = self.playing and 1 or 0.5 + math.cos(total_rads * 2) * 0.5
    love.graphics.setColor(1, 1, 1, alpha)
    local length = 2.3
    local step = self.step_size
    for i = -1.5, 1.5, 1 do
        love.graphics.line(i * step, -length * step, i * step, length * step)
        love.graphics.line(-length * step, i * step, length * step, i * step)
    end
    local wins = math.ceil(self.wins)

    love.graphics.setColor(1, 1, 1, alpha)
    for i = 1, wins, 1 do
        local pos = self:_dotPos(i)
        love.graphics.circle('fill', pos.x, pos.y, self.dot_size)
    end

    love.graphics.origin()

    if self.win_tween ~= nil then
        love.graphics.circle('fill', self.win_tween.subject.x, self.win_tween.subject.y, self.dot_size)
    end
end

function Status:_dotPos(win)
    local x = (win - 1) % 5 - 2
    local y = math.ceil(win / 5) - 3
    return { x = x * self.step_size, y = y * self.step_size }
end

-- Called at start of intermission state.
function Status:prepareWin(start_pos)
    self.win_tween = tween.new(math.pi, start_pos, { x = 0, y = 0 }, 'inCubic')
    self:_updateWinTweenTarget()
end

function Status:_updateWinTweenTarget()
    local end_pos = self:_dotPos(self.wins + 1)

    -- TODO use vector more?
    end_pos = vector(end_pos.x, end_pos.y)
    end_pos:rotateInplace(self.angle)
    end_pos = self.display_v + end_pos

    self.win_tween.target.x, self.win_tween.target.y = end_pos:unpack()
end

-- Called at end of intermission state.
function Status:confirmWin()
    if self.win_tween ~= nil then
        self.wins = self.wins + 1
        self.win_tween = nil
    end
    return self.wins
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
