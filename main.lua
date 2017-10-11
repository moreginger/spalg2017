Gamestate = require 'hump.gamestate'

local init = require 'states.init'
local pause = require 'states.pause'

-- require 'test'

function love.load()
    -- test()
    Gamestate.registerEvents()
    Gamestate.switch(init)
end

function love.visible(visible)
    if not visible then
        Gamestate.switch(pause)
    end
end
