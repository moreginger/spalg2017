Gamestate = require 'hump.gamestate'

local init = require 'states.init'

require 'test'

function love.load()
    -- test()
    Gamestate.registerEvents()
    Gamestate.switch(init)
end
