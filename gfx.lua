local c1, c2 = love.graphics.newCanvas(), love.graphics.newCanvas()

function build_shader(taps, offset, offset_type, sigma)
    taps = math.floor(taps)
    sigma = sigma >= 1 and sigma or (taps - 1) * offset / 6
    sigma = math.max(sigma, 1)
  
    local steps = (taps + 1) / 2
  
    -- Calculate gaussian function.
    local g_offsets = {}
    local g_weights = {}
    for i = 1, steps, 1 do
          g_offsets[i] = offset * (i - 1)
  
      -- We don't need to include the constant part of the gaussian function as we normalize later.
      -- 1 / math.sqrt(2 * sigma ^ math.pi) * math.exp(-0.5 * ((offset - 0) / sigma) ^ 2 )
      g_weights[i] = math.exp(-0.5 * (g_offsets[i] - 0) ^ 2 * 1 / sigma ^ 2 )
    end
  
    -- Calculate offsets and weights for sub-pixel samples.
    local offsets = {}
    local weights = {}
    for i = #g_weights, 2, -2 do
      local oA, oB = g_offsets[i], g_offsets[i - 1]
      local wA, wB = g_weights[i], g_weights[i - 1]
      wB = oB == 0 and wB / 2 or wB -- On center tap the middle is getting sampled twice so half weight.
      local weight = wA + wB
      offsets[#offsets + 1] = offset_type == 'center' and (oA + oB) / 2 or (oA * wA + oB * wB) / weight
      weights[#weights + 1] = weight
    end
  
    local code = {[[
      extern vec2 direction;
      vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {]]}
  
    local norm = 0
    if #g_weights % 2 == 0 then
      code[#code+1] =  'vec4 c = vec4( 0.0f );'
    else
      local weight = g_weights[1]
      norm = norm + weight
      code[#code+1] = ('vec4 c = %f * texture2D(tex, tc);'):format(weight)
    end
  
    local tmpl = 'c += %f * ( texture2D(tex, tc + %f * direction)+ texture2D(tex, tc - %f * direction));\n'
    for i = 1, #offsets, 1 do
      local offset = offsets[i]
      local weight = weights[i]
      norm = norm + weight * 2
      code[#code+1] = tmpl:format(weight, offset, offset)
    end
    code[#code+1] = ('return c * vec4(%f) * color; }'):format(1 / norm)

    local shader = table.concat(code)
    return love.graphics.newShader(shader)
end

local shader = build_shader(9, 1, 'center', -1)

function drawGame(players, map, draw_map_end, shaders)
    love.graphics.setColor(255, 255, 255, 255)

    local ps = love.graphics.getShader()
    local pc = love.graphics.setCanvas()
    local pbm = love.graphics.getBlendMode()

    love.graphics.setCanvas(c1)
    love.graphics.clear()
    _drawGameInternal(players, map, draw_map_end, shaders.cfg_all)

    love.graphics.setShader(shader)
    love.graphics.setBlendMode("alpha", "premultiplied")
    shader:send('direction', {1 / love.graphics.getWidth(), 0})
    love.graphics.setCanvas(c2)
    love.graphics.clear()
    love.graphics.draw(c1, 0, 0)
    shader:send('direction', {0, 1 / love.graphics.getHeight()})
    love.graphics.setCanvas(pc)
    love.graphics.draw(c2, 0, 0)

    love.graphics.setBlendMode(pbm)
    love.graphics.setShader(ps)

    _drawGameInternal(players, map, draw_map_end, shaders.cfg_all)
end

function draw(buffer)
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
