-- Magenta, red, green, blue, yellow, cyan
local pixelColors = { { 255, 0, 255 }, { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 }, { 255, 255, 0 }, { 0, 255, 255 } }
-- Line color
local black = { 0, 0, 0 }

local numPixels = 25
-- The reciprocal of the added width
local colorPickerWidth = 6

local screenHeight = 1080
local screenWidth = screenHeight + (screenHeight / colorPickerWidth)

local liney = 10
local linex = {
	screenWidth - (screenHeight / colorPickerWidth) - liney / 2,
	screenWidth - (screenHeight / colorPickerWidth) + liney / 2,
}
local zigzagline = {}
for i = 0, screenHeight / liney do
	table.insert(zigzagline, linex[i % 2 + 1])
	table.insert(zigzagline, liney * i)
end

math.randomseed(os.time())

-- Table of pixels
local rectangles = {}
for i = 1, numPixels do
	table.insert(rectangles, {})
	for j = 1, numPixels do
		table.insert(rectangles[i], {
			color = pixelColors[math.random(6)],
			x = screenHeight / numPixels * (i - 1),
			y = screenHeight / numPixels * (j - 1),
		})
	end
end

function love.load()
	love.window.setMode(screenWidth, screenHeight)
	love.window.setTitle("Pixel painter 🦙🖌️")
	love.graphics.setBackgroundColor(black)
end

-- Input

function love.mousereleased(x, y, button, _, _)
	if x > screenHeight and button == 1 then
		-- Figure out which color was picked
		-- y / 180 -> y / (screenHeight / pixelColors.length)
		-- floor   -> we don't care where in the box was clicked, chop off decimal
		-- + 1     -> lua is not zero indexed :(
		local colorPicked = pixelColors[math.floor(y / 180) + 1]
		Change_color(colorPicked)
	end
end

function love.keyreleased(key)
	if key == "q" then
		os.exit()
	elseif string.match("123456", key) then
		Change_color(pixelColors[tonumber(key)])
	end
end

-- https://en.wikipedia.org/wiki/Flood_fill#Moving_the_recursion_into_a_data_structure
-- Queue based
function Change_color(colorTo)
	local pixelsToChange = {}
	table.insert(pixelsToChange, rectangles[1][1])
	local colorFrom = rectangles[1][1].color
	while next(pixelsToChange) ~= nil do
		local p = table.remove(pixelsToChange, 1)
		if p.color == colorFrom then
			p.color = colorTo
			local loc = FindPixel(p)
			if loc.col ~= 1 then
				table.insert(pixelsToChange, rectangles[loc.col - 1][loc.row])
			end
			if loc.col ~= numPixels then
				table.insert(pixelsToChange, rectangles[loc.col + 1][loc.row])
			end
			if loc.row ~= 1 then
				table.insert(pixelsToChange, rectangles[loc.col][loc.row - 1])
			end
			if loc.row ~= numPixels then
				table.insert(pixelsToChange, rectangles[loc.col][loc.row + 1])
			end
		end
	end
end

-- Optimize... O(n^2)
function FindPixel(pixel)
	for i, arr in ipairs(rectangles) do
		for j, rect in ipairs(arr) do
			if rect == pixel then
				return { col = i, row = j }
			end
		end
	end
end

function love.draw()
	-- Draw pixels
	for _, arr in pairs(rectangles) do
		for _, rect in pairs(arr) do
			love.graphics.setColor(rect.color)
			love.graphics.rectangle("fill", rect.x, rect.y, screenHeight / numPixels, screenHeight / numPixels)
		end
	end
	-- Draw color picker
	for i = 1, #pixelColors do
		love.graphics.setColor(pixelColors[i])
		love.graphics.rectangle(
			"fill",
			screenWidth - (screenWidth - screenHeight),
			screenHeight / #pixelColors * (i - 1),
			screenWidth - screenHeight,
			screenHeight / #pixelColors
		)
	end
	-- Draw line
	love.graphics.setColor(black)
	love.graphics.line(zigzagline)
end
