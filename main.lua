-- Magenta, red, green, blue, yellow, cyan
-- local oldColors = { { 255, 0, 255 }, { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 }, { 255, 255, 0 }, { 0, 255, 255 } }
local pixelColors = {
	{ 198 / 255, 160 / 255, 246 / 255 },
	{ 202 / 255, 211 / 255, 245 / 255 },
	{ 138 / 255, 173 / 255, 244 / 255 },
	{ 166 / 255, 218 / 255, 149 / 255 },
	{ 245 / 255, 169 / 255, 127 / 255 },
	{ 237 / 255, 135 / 255, 150 / 255 },
}

local numPixels = 16

local screenHeight = 512
local screenWidth = screenHeight
-- 2/3 of screenHeight
local canvasHeight = screenHeight / 3 * 2
local canvasStrokeWidth = 10

-- TODO: tie to screenHeight
local paletteLocs = {
	{ x = 360, y = 375, radx = 20, rady = 23 },
	{ x = 400, y = 340, radx = 20, rady = 23 },
	{ x = 440, y = 320, radx = 20, rady = 23 },
	{ x = 485, y = 340, radx = 20, rady = 23 },
	{ x = 475, y = 390, radx = 20, rady = 23 },
	{ x = 440, y = 430, radx = 20, rady = 23 },
}
local font
-- Turn counter, also used for difficulty message box title
local txtTurns = "New game"

function StartGame()
	local difficulty = love.window.showMessageBox(txtTurns, "Choose your difficulty:", { "Easy", "Normal", "Hard" })
	if difficulty == 1 then
		numPixels = 12
	elseif difficulty == 2 then
		numPixels = 16
	elseif difficulty == 3 then
		numPixels = 21
	else
		numPixels = 16
	end
	TurnsLeft = numPixels + 11
	PixelSize = (canvasHeight - 2 * canvasStrokeWidth) / numPixels

	math.randomseed(os.time())

	-- Table of pixels
	Rectangles = {}
	RectLookup = {}
	for i = 1, numPixels do
		table.insert(Rectangles, {})
		for j = 1, numPixels do
			local rect = {
				color = pixelColors[math.random(#pixelColors)],
				x = PixelSize * (i - 1) + 10,
				y = PixelSize * (j - 1) + 10,
			}
			table.insert(Rectangles[i], rect)
			RectLookup[rect] = { col = i, row = j }
		end
	end
end

function EndGame(won)
	if won then
		txtTurns = "You Won! :)"
	else
		txtTurns = "You lost :("
	end
	StartGame()
end

function love.load()
	love.window.setMode(screenWidth, screenHeight)
	love.window.setTitle("Pixel painter 🦙🖌️")
	love.graphics.setBackgroundColor({ 1, 1, 1 })
	BG = love.graphics.newImage("img/background.png")
	PAINTBRUSH = love.graphics.newImage("img/paintbrush.png")
	PAINTBRUSH_BRUSH = love.graphics.newImage("img/paintbrush_brush.png")
	GLASS = love.graphics.newImage("img/glass.png")
	PALETTE = love.graphics.newImage("img/palette.png")
	font = love.graphics.newFont(math.floor(screenHeight / 15))
	love.graphics.setFont(font)
	txtTurns = "Turns Left: " .. TurnsLeft
end

-- Input

function love.mousereleased(x, y, button, _, _)
	if x > canvasHeight and button == 1 then
		-- Figure out which color was picked
		local colorPicked = Rectangles[1][1].color
		for i, loc in ipairs(paletteLocs) do
			if
				x >= loc.x - loc.radx
				and y >= loc.y - loc.rady
				and x <= (loc.x + loc.radx)
				and y <= (loc.y + loc.rady)
			then
				colorPicked = pixelColors[i]
			end
		end
		if colorPicked ~= Rectangles[1][1].color then
			ChangeColor(colorPicked)
		end
	end
end

function love.keyreleased(key)
	if key == "q" then
		os.exit()
	-- Check that string is only a digit from 1-6
	elseif string.match(key, "^[123456]$") then
		local colorPicked = pixelColors[tonumber(key)]
		if colorPicked ~= Rectangles[1][1].color then
			ChangeColor(colorPicked)
		end
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
		else
			TurnsLeft = TurnsLeft - 1
			txtTurns = "Turns Left: " .. TurnsLeft
		end
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
	love.graphics.setColor({ 1, 1, 1 })
	-- Draw background
	love.graphics.draw(BG)
	-- Draw Turns Left
	--love.graphics.setColor({ 202 / 255, 211 / 255, 245 / 255 })
	-- Draw pixels
	for _, arr in pairs(Rectangles) do
		for _, rect in pairs(arr) do
			love.graphics.setColor(rect.color)
			love.graphics.rectangle("fill", rect.x, rect.y, PixelSize, PixelSize)
		end
	end
	love.graphics.setColor({ 1, 1, 1 })
	love.graphics.draw(PAINTBRUSH)
	love.graphics.setColor(Rectangles[1][1].color)
	love.graphics.draw(PAINTBRUSH_BRUSH)
	-- Shadow
	love.graphics.setColor({ 36 / 255, 39 / 255, 58 / 255 })
	love.graphics.draw(PALETTE, 0, 0, 0, 1, 1, 10, 2)
	love.graphics.setColor({ 1, 1, 1 })
	love.graphics.draw(GLASS)
	love.graphics.draw(PALETTE)
	-- Draw color picker
	for i, loc in ipairs(paletteLocs) do
		love.graphics.setColor(pixelColors[i])
		love.graphics.ellipse("fill", loc.x, loc.y, loc.radx, loc.rady)
	end
	love.graphics.setColor({ 36 / 255, 39 / 255, 58 / 255 })
	love.graphics.print(txtTurns, screenWidth / 10, screenHeight - (screenHeight / 5))
end

StartGame()
