--Magenta, red, green, blue, yellow, cyan
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
	for j = 1, numPixels do
		table.insert(rectangles, {
			color = pixelColors[math.random(6)],
			x = screenHeight / numPixels * (i - 1),
			y = screenHeight / numPixels * (j - 1),
		})
	end
end

local colorPicked = rectangles[1].color

function love.load()
	love.window.setMode(screenWidth, screenHeight)
	love.window.setTitle("Pixel painter 🦙🖌️")
	love.graphics.setBackgroundColor({ 0, 0, 0 })
end

function love.mousereleased(x, y, button, istouch, presses)
	if x > screenHeight and button == 1 then
		-- Figure out which color was picked
		-- y / 180 -> y / (screenHeight / pixelColors.length)
		-- floor   -> we don't care where in the box was clicked, chop off decimal
		-- + 1     -> lua is not zero indexed :(
		colorPicked = pixelColors[math.floor(y / 180) + 1]
	end
end

function love.draw()
	-- Draw pixels
	for _, rect in pairs(rectangles) do
		love.graphics.setColor(rect.color)
		love.graphics.rectangle("fill", rect.x, rect.y, screenHeight / numPixels, screenHeight / numPixels)
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
