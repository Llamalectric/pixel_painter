-- Magenta, red, green, blue, yellow, cyan
local oldColors = { { 255, 0, 255 }, { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 }, { 255, 255, 0 }, { 0, 255, 255 } }
local pixelColors = {
	{ 198 / 255, 160 / 255, 246 / 255 },
	{ 202 / 255, 211 / 255, 245 / 255 },
	{ 138 / 255, 173 / 255, 244 / 255 },
	{ 166 / 255, 218 / 255, 149 / 255 },
	{ 245 / 255, 169 / 255, 127 / 255 },
	{ 237 / 255, 135 / 255, 150 / 255 },
}
local lineColor = { 36 / 255, 39 / 255, 58 / 255 }

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

function StartGame(num)
	numPixels = num or 16
	TurnsLeft = numPixels + 11

	math.randomseed(os.time())

	-- Table of pixels
	Rectangles = {}
	RectLookup = {}
	for i = 1, numPixels do
		table.insert(Rectangles, {})
		for j = 1, numPixels do
			local rect = {
				color = pixelColors[math.random(#pixelColors)],
				x = screenHeight / numPixels * (i - 1),
				y = screenHeight / numPixels * (j - 1),
			}
			table.insert(Rectangles[i], rect)
			RectLookup[rect] = { col = i, row = j }
		end
	end
end

function EndGame(won)
	if won then
		print("You won!")
	else
		print("You lost :(")
	end
	StartGame()
end

function love.load()
	love.window.setMode(screenWidth, screenHeight)
	love.window.setTitle("Pixel painter 🦙🖌️")
	love.graphics.setBackgroundColor(lineColor)
end

-- Input

function love.mousereleased(x, y, button, _, _)
	if x > screenHeight and button == 1 then
		-- Figure out which color was picked
		-- y / 180 -> y / (screenHeight / pixelColors.length)
		-- floor   -> we don't care where in the box was clicked, chop off decimal
		-- + 1     -> lua is not zero indexed :(
		local colorPicked = pixelColors[math.floor(y / (screenHeight / #pixelColors)) + 1]
		ChangeColor(colorPicked)
	end
end

function love.keyreleased(key)
	if key == "q" then
		os.exit()
	elseif string.match("123456", key) then
		ChangeColor(pixelColors[tonumber(key)])
	end
end

-- https://en.wikipedia.org/wiki/Flood_fill#Moving_the_recursion_into_a_data_structure
-- Queue based
function ChangeColor(colorTo)
	local pixelsToChange = {}
	local pixelsVisited = {}
	table.insert(pixelsToChange, Rectangles[1][1])
	local colorFrom = Rectangles[1][1].color
	while #pixelsToChange > 0 do
		local p = table.remove(pixelsToChange, 1)
		pixelsVisited[p] = true
		if p.color == colorFrom then
			p.color = colorTo
			local loc = RectLookup[p]
			-- We can throw away p's value and use it to keep the next part more concise
			if loc.col > 1 then
				p = Rectangles[loc.col - 1][loc.row]
				if not pixelsVisited[p] then
					table.insert(pixelsToChange, p)
					pixelsVisited[p] = true
				end
			end
			if loc.col < numPixels then
				p = Rectangles[loc.col + 1][loc.row]
				if not pixelsVisited[p] then
					table.insert(pixelsToChange, p)
					pixelsVisited[p] = true
				end
			end
			if loc.row > 1 then
				p = Rectangles[loc.col][loc.row - 1]
				if not pixelsVisited[p] then
					table.insert(pixelsToChange, p)
					pixelsVisited[p] = true
				end
			end
			if loc.row < numPixels then
				p = Rectangles[loc.col][loc.row + 1]
				if not pixelsVisited[p] then
					table.insert(pixelsToChange, p)
					pixelsVisited[p] = true
				end
			end
		end
	end
	if CheckWin(colorTo) then
		EndGame(true)
	else
		if TurnsLeft <= 0 then
			EndGame(false)
		end
		TurnsLeft = TurnsLeft - 1
	end
end

function CheckWin(winningColor)
	for _, arr in pairs(Rectangles) do
		for _, rect in pairs(arr) do
			if rect.color ~= winningColor then
				return false
			end
		end
	end
	return true
end

function love.draw()
	-- Draw pixels
	for _, arr in pairs(Rectangles) do
		for _, rect in pairs(arr) do
			love.graphics.setColor(rect.color)
			love.graphics.rectangle("fill", rect.x, rect.y, screenHeight / numPixels, screenHeight / numPixels)
		end
	end
	-- Draw color picker
	for i, color in ipairs(pixelColors) do
		love.graphics.setColor(color)
		love.graphics.rectangle(
			"fill",
			screenWidth - (screenWidth - screenHeight),
			screenHeight / #pixelColors * (i - 1),
			screenWidth - screenHeight,
			screenHeight / #pixelColors
		)
	end
	-- Draw line
	love.graphics.setColor(lineColor)
	love.graphics.line(zigzagline)
end

StartGame()
