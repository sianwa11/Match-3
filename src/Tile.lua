--[[

	The individual tiles that make up the game board
]]


Tile = Class{}

function Tile:init(x, y, color, variety)
	--board positions
	self.gridX = x
	self.gridY = y

	--coordinate positions
	self.x = (self.gridX - 1) * 32
	self.y = (self.gridY - 1) * 32

	--tile appearance/points
	self.color = color
	self.variety = variety
end

function Tile:update(dt)
	
end

--[[
	Function to swap this tile with another, tweening the two positions
	]]
function Tile:swap(tile)
	
end


function Tile:render(x, y)
	--draw shadow
	love.graphics.setColor(0.1, 0.1, 0.2, 1)
	love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
			self.x + x + 2, self.y + y + 2)

	--draw title itself
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(gTextures['main'], gFrames['tiles'][self.color][self.variety],
			self.x + x, self.y + y)
end