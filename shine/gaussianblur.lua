--[[
The MIT License (MIT)

Copyright (c) 2015 Matthias Richter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

-- unroll convolution loop
local function build_shader(taps)
	local taps = math.floor(taps)
	if taps < 1 or taps % 2 ~= 1 then
	    error(('Taps must be >0 and odd. Was %d.'):format(taps))
	end

	-- Sigma is smaller than taps.
	local sigma = (taps - 1) / 6
	print('sigma', sigma)
	local steps = (taps + 1) / 2

	local g_offsets = {}
	local g_weights = {}
	for i = 1, steps, 1 do
		local offset = i - 1
		g_offsets[i] = offset

		-- We don't need to include the fixed function as we normalize later anyway.
		-- g_weights[i] = 1 / math.sqrt(2 * sigma ^ math.pi) * math.exp(-0.5 * ((offset - 0) / sigma) ^ 2 )
		g_weights[i] = math.exp(-0.5 * (offset - 0) ^ 2 * 1 / sigma ^ 2 )
		print('weight', i, g_weights[i])
	end

	local offsets = {}
	local weights = {}
	for i = #g_weights, 2, -2 do
		local oA, oB = g_offsets[i], g_offsets[i - 1]
		local wA, wB = g_weights[i], g_weights[i - 1]
		wB = i ~=2 and wB or wB / 2 -- On final tap the middle is getting sampled twice so half weight.
		local weight = wA + wB
		offsets[#offsets + 1] = (oA * wA + oB * wB) / weight
		weights[#weights + 1] = weight
	end

	local code = {[[
extern vec2 direction;
uniform sampler2D tex0;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
{
    vec4 colOut = vec4( 0.0f );
]]}

	local tmpl = '    colOut += %f * ( texture2D( tex0, tc + %f * direction ).xyzw + texture2D( tex0, tc - %f * direction ).xyzw );\n'

	local norm = 0
	for i = 1, #offsets, 1 do
		local offset = offsets[i]
		local weight = weights[i]
		norm = norm + weight * 2
		code[#code+1] = tmpl:format(weight, offset, offset)
	end
	if #g_weights % 2 == 1 then
		local weight = g_weights[1]
		norm = norm + weight
		code[#code+1] = ('    colOut += %f * texture2D( tex0, tc).xyzw;'):format(weight)
	end
	code[#code+1] = ('    return colOut * vec4(%f);}'):format(1 / norm)

	local shader = table.concat(code)
	print(shader)
	return love.graphics.newShader(shader)
end

return {
description = "Fast Gaussian blur shader",

new = function(self)
	self.canvas_h, self.canvas_v = love.graphics.newCanvas(), love.graphics.newCanvas()
	self.shader = build_shader(7)
	self.shader:send("direction",{1.0,0.0})
end,

draw = function(self, func, ...)
	local c = love.graphics.getCanvas()
	local s = love.graphics.getShader()
	local co = {love.graphics.getColor()}

	-- draw scene
	self:_render_to_canvas(self.canvas_h, func, ...)

	love.graphics.setColor(co)
	love.graphics.setShader(self.shader)

	local b = love.graphics.getBlendMode()
	love.graphics.setBlendMode('alpha', 'premultiplied')

	-- first pass (horizontal blur)
	self.shader:send('direction', {1 / love.graphics.getWidth(), 0})
	self:_render_to_canvas(self.canvas_v, love.graphics.draw, self.canvas_h, 0,0)

	-- second pass (vertical blur)
	self.shader:send('direction', {0, 1 / love.graphics.getHeight()})
	love.graphics.draw(self.canvas_v, 0,0)

	-- restore blendmode, shader and canvas
	love.graphics.setBlendMode(b)
	love.graphics.setShader(s)
	love.graphics.setCanvas(c)
end,

set = function(self, key, value)
	if key == "taps" then
		self.shader = build_shader(tonumber(value))
	else
		error("Unknown property: " .. tostring(key))
	end
	return self
end
}
