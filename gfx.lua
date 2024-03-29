local c1, intermediate = love.graphics.newCanvas(), love.graphics.newCanvas()

local logo_font, status_font, trail_length_font, trail_color, trail_blur, pause_blur

local gfx = {
}

function gfx.init(trail_width, trail_radius)
  logo_color = { 0.5, 1, 0.5, 0.8 }
  logo_font = love.graphics.newFont('resources/comfortaa.bold.ttf', trail_radius * 3)
  pause_blur = _build_shader(19, 1, 'center', -1, 2)
  status_font = love.graphics.newFont('resources/comfortaa.bold.ttf', trail_radius / 2)
  trail_blur = _build_shader(9, 1, 'center', -1, 1)
  trail_color = { 0, 1, 0, 1 }
  trail_length_font = love.graphics.newFont('resources/comfortaa.bold.ttf', trail_radius / 3.2)
end

function _build_shader(taps, offset, offset_type, sigma, mult)
    taps = math.floor(taps)
    sigma = sigma >= 1 and sigma or (taps - 1) * offset / 6
    sigma = math.max(sigma, 1)
    mult = math.sqrt(mult) -- We apply this twice (two passes)

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
    code[#code+1] = ('return c * vec4(%f) * color; }'):format(mult / norm)

    local shader = table.concat(code)
    return love.graphics.newShader(shader)
end

function gfx.statusFont()
  return status_font
end

function gfx.drawGame(state, draw_map_end)
    local players, map = state.players, state.map
    local pc = love.graphics.getCanvas()
    love.graphics.setCanvas(c1)
    love.graphics.clear()
    _drawGameInternal(players, map, draw_map_end)
    _applyBlur(trail_blur, pc)
    _drawGameInternal(players, map, draw_map_end) -- If we apply from the canvas instead the quality of aliasing is lower.
end

function gfx.pauseBlur(dest)
    _applyBlur(pause_blur, dest)
end

function gfx.drawLogo()
  love.graphics.setColor(logo_color[1], logo_color[2], logo_color[3], logo_color[4])
  love.graphics.setFont(logo_font)
  love.graphics.print('spalg', 10, 10)
end

function _drawGameInternal(players, map, draw_map_end)
    for i = 1, #players do
        players[i]:draw(trail_length_font, trail_color)
      end
      map:drawArc(trail_color)
      if draw_map_end then
        map:drawEnd(trail_length_font, trail_color, 1, map:length())
    end
end

function _applyBlur(shader, dest)
  local source = love.graphics.getCanvas()
  local ps = love.graphics.getShader()
  local pbm = love.graphics.getBlendMode()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setShader(shader)
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.setCanvas(intermediate)
  love.graphics.clear()
  shader:send('direction', {1 / love.graphics.getWidth(), 0})
  love.graphics.draw(source, 0, 0)
  shader:send('direction', {0, 1 / love.graphics.getHeight()})
  love.graphics.setCanvas(dest)
  love.graphics.draw(intermediate, 0, 0)

  love.graphics.setBlendMode(pbm)
  love.graphics.setShader(ps)
end

return gfx
