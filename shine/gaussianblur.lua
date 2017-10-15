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
	local support = math.max(1, math.floor(3*sigma + .5))
	local one_by_sigma_sq = sigma > 0 and 1 / (sigma * sigma) or 1
	local norm = 0



	local code = {[[
		extern vec2 direction;
		uniform sampler2D tex0;
		vec4 effect(vec4 color, Image texture, vec2 tc, vec2 sc)
		{
		vec3 colOut = vec3( 0.0f );

	vec2 texCoordOffset = 0.53805f * direction;
	vec3 col = texture2D( tex0, tc + texCoordOffset ).xyz + texture2D( tex0, tc - texCoordOffset ).xyz;
	colOut += 0.44908f * col;
	texCoordOffset = 2.06278f * direction;
	col = texture2D( tex0, tc + texCoordOffset ).xyz + texture2D( tex0, tc - texCoordOffset ).xyz;
	colOut += 0.05092f * col;
return vec4(colOut, 1.0f);
}
	]]}

	return love.graphics.newShader(table.concat(code))
end

return {
description = "Fast Gaussian blur shader",

new = function(self)
	self.canvas_h, self.canvas_v = love.graphics.newCanvas(), love.graphics.newCanvas()
	self.shader = build_shader(1)
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
	self:_render_to_canvas(self.canvas_v,
	                       love.graphics.draw, self.canvas_h, 0,0)

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
