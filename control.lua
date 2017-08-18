Control = {
    region = nil,
    key = nil
}

function Control:isChangeDirectionKey(key)
    return self.key == key
end

function Control:isChangeDirectionTouch(x, y)
    return self.region:contains(x, y)
end

function Control:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
