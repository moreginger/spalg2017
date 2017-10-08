Gamestate = require 'hump.gamestate'

local init = require 'states.init'
local pause = require 'states.pause'

require 'test'

function love.load()
    -- test()
    Gamestate.registerEvents()
    Gamestate.switch(init)
end

function love:focus(f)
    if f then
        -- Gamestate.push(pause)
    end
end
