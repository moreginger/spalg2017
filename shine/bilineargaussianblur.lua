--[[
The MIT License (MIT)

Copyright (c) 2017 Tim Moore

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

-- Bilinear Gaussian blur filter as detailed here: http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
-- Produces near identical results to a standard Gaussian blur by using sub-pixel sampling,
-- this allows us to do ~1/2 the number of pixel lookups.

-- unroll convolution loop
local function build_shader(taps, offset, offset_type, sigma)
	taps = math.floor(taps)
	if taps < 3 or taps % 2 ~= 1 then
	    error(('taps must be >=3 and odd. Was %d.'):format(taps))
	end

	if offset_type ~= 'weighted' and offset_type ~= 'center' then
	    error(('offset_type must be \'weighted\' or \'center\'. Was %s.'):format(offset_type))
	end

	sigma = sigma >= 1 and sigma or (taps - 1) * offset / 6
	sigma = math.max(sigma, 1)

	local steps = (taps + 1) / 2

	-- Calculate gaussian function.
	local g_offsets = {}
	local g_weights = {}
	local norm = 0
	for i = 1, steps, 1 do
		g_offsets[i] = offset * (i - 1)

		-- We don't need to include the constant part of the gaussian function as we normalize later.
		-- 1 / math.sqrt(2 * sigma ^ math.pi) * math.exp(-0.5 * ((offset - 0) / sigma) ^ 2 )
		weight = math.exp(-0.5 * (g_offsets[i] - 0) ^ 2 * 1 / sigma ^ 2 )
		g_weights[i] = weight
		norm = norm + (i == 1 and weight or weight * 2)
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
uniform sampler2D tex0;
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc) {]]}

	if #g_weights % 2 == 0 then
		code[#code+1] =  'vec3 c = vec3( 0.0f );'
	else
		local weight = g_weights[1]
		code[#code+1] = ('vec3 c = %f * texture2D( tex0, tc ).rgb;'):format(weight)
	end

	local tmpl = 'c += %f * ( texture2D( tex0, tc + %f * direction ).rgb + texture2D( tex0, tc - %f * direction ).rgb );\n'
	for i = 1, #offsets, 1 do
		local offset = offsets[i]
		local weight = weights[i]
		code[#code+1] = tmpl:format(weight, offset, offset)
	end
	code[#code+1] = ('return %f * vec4(c, 1.0f) * color; }'):format(1 / norm)

	local shader = table.concat(code)
	return love.graphics.newShader(shader)
end

return {

description = "Bilinear Gaussian blur shader (http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/)",

new = function(self)
	self.canvas_h, self.canvas_v = love.graphics.newCanvas(), love.graphics.newCanvas()
	self.taps, self.offset, self.offset_type, self.sigma = 7, 1, 'weighted', -1
	self.shader = build_shader(self.taps, self.offset, self.offset_type, self.sigma)

	self.shader:send("direction", {1.0, 0.0} )
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
		-- Number of effective samples to take per pass. e.g. 3-tap is the current pixel and the neighbors each side.
		-- More taps = larger blur, but slower.
		self.taps = tonumber(value)
	elseif key == "offset" then
		-- Offset of each tap.
		-- For highest quality this should be <=1 but if the image has low entropy we
		-- can approximate the blur with a number > 1 and less taps, for better performance.
		self.offset = tonumber(value)
	elseif key == "offset_type" then
		-- Offset type, either 'weighted' or 'center'.
		-- 'weighted' gives a more accurate gaussian decay but can introduce modulation
		-- for high frequency details.
	elseif key == "sigma" then
		-- Sigma value for gaussian distribution. You don't normally need to set this.
	    self.sigma = tonumber(value)
	else
		error("Unknown property: " .. tostring(key))
	end

	self.shader = build_shader(self.taps, self.offset, self.offset_type, self.sigma)
	return self
end
}
