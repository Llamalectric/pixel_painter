local magenta = { 255, 0, 255 }
local red = { 255, 0, 0 }
local green = { 0, 255, 0 }
local blue = { 0, 0, 255 }
local yellow = { 255, 255, 0 }
local cyan = { 0, 255, 255 }

local pixelColors = { magenta, red, green, blue, yellow, cyan }
-- Background color
local white = { 255, 255, 255 }

local numPixels = 25
-- The reciprocal of the added width
local colorPickerWidth = 6

local screenHeight = 1080
local screenWidth = screenHeight + screenHeight / colorPickerWidth

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

math.randomseed(0)

function love.load()
	love.window.setMode(screenWidth, screenHeight)
	love.graphics.setBackgroundColor({ 0, 0, 0 })
end

function love.draw()
	for i = 1, numPixels do
		love.graphics.setColor(pixelColors[math.random(6)])
		love.graphics.rectangle(
			"fill",
			screenHeight / numPixels * (i - 1),
			0,
			screenHeight / numPixels,
			screenHeight / numPixels
		)
	end
	-- Draw line
	love.graphics.setColor(white)
	love.graphics.line(zigzagline)
end
