Gamestate = require 'hump.gamestate'

local init = require 'states.init'
local pause = require 'states.pause'

function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(init)
end

function love.visible(visible)
    if not visible then
        Gamestate.switch(pause)
    end
end
