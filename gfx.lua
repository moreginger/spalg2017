function drawGame(players, map, draw_map_end, shaders)
    shaders.trail:draw(function()
        love.graphics.setColor(255, 255, 255, 255)
        _drawGameInternal(players, map, draw_map_end, shaders.cfg_all)
    end)
    love.graphics.setColor(255, 255, 255, 255)
    _drawGameInternal(players, map, draw_map_end, shaders.cfg_all)
end

function _drawGameInternal(players, map, draw_map_end, cfg)
    for i = 1, #players do
        players[i]:draw(cfg)
    end
    map:draw()
    if draw_map_end then
        map:drawEndDot(1)
    end
end
