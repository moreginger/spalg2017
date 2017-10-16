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
local function build_shader(sigma)
	local sigma = math.floor(sigma)
	if sigma < 1 or sigma % 2 ~= 1 then
	    error(('Sigma must be >0 and odd. Was %d.'):format(sigma))
	end
	local steps = (math.floor(sigma) + 1) / 2

	local g_offset = {}
	local g_weight = {}
	for i = 1, steps, 1 do
		g_offset[i] = i - 1
		-- TODO gaussian function
		g_weight[i] = 1 / ( i * i )
	end

	local offset = {}
	local weight = {}
	for i = #g_weight, 2, -2 do
		local oA, oB = g_offset[i], g_offset[i - 1]
		local wA, wB = g_weight[i], g_weight[i - 1]
		offset[#offset + 1] = (oA * wA + oB * wB) / (wA + wB)
		weight[#weight + 1] = wA + wB
	end

	-- TODO centre


	local code = {[[
extern vec2 direction;
uniform sampler2D tex0;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
{
    vec3 colOut = vec3( 0.0f );
]]}

	local tmpl = '    colOut += %f * ( texture2D( tex0, tc + %f * direction ).xyz + texture2D( tex0, tc - %f * direction ).xyz );\n'

	local norm = 0
	for i = 1, #offset, 1 do
		local offset = offset[i]
		local weight = weight[i]
		norm = norm + weight * 2
		code[#code+1] = tmpl:format(weight, offset, offset)
	end
	print(#g_weight)
	if #g_weight % 2 == 0 then
		print('case 1')
		local weight = g_weight[1]
		norm = norm + weight
		code[#code+1] = ('    colOut += %f * texture2D( tex0, tc).xyz;'):format(weight)
	else
		-- TODO avoid duplicating code
		print('case 2')
		local oA, oB = g_offset[2], g_offset[1];
		local wA, wB = g_weight[2], g_weight[1]
		local weight = wA + wB
		norm = norm + weight * 2
		local offset = (oA * wA + oB * wB) / (wA + wB)
		code[#code+1] = tmpl:format(weight, offset, offset)
	end
	code[#code+1] = ('    return vec4(colOut, 1.0f) * vec4(%f);}'):format(1 / norm)

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
	if key == "sigma" then
		self.shader = build_shader(tonumber(value))
	else
		error("Unknown property: " .. tostring(key))
	end
	return self
end
}
