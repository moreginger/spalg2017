Gamestate = require 'hump.gamestate'

init = require 'states.init'
game = require 'game'

require 'test'

function love.load()
  -- test()
  init:load()
  game:load()
  Gamestate.registerEvents()
  Gamestate.switch(init)
  Gamestate.switch(game)
end
