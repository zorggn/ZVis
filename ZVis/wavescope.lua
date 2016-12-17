-- ZVis - WaveScope implementation
-- zorg @ 2016 § ISC

-- Class
local visualizer = {}

-- Getters
visualizer.getWindowPosition = function(vis) return vis.left, vis.top end
visualizer.getWindowDimensions = function(vis) return vis.width, vis.height end

-- Setters
visualizer.setWindowPosition = function(vis, left, top)
	assert(type(left) == 'number' or type(left) == 'nil', "Visualizer's left position must be a number.")
	assert(type(top)  == 'number' or type(top)  == 'nil', "Visualizer's top position must be a number.")
	vis.left = left or vis.left
	vis.top  = top  or vis.top
end
visualizer.setWindowDimensions = function(vis, width, height)
	assert(type(width)  == 'number' or type(width)  == 'nil', "Visualizer's width must be a number.")
	assert(type(height) == 'number' or type(height) == 'nil', "Visualizer's height must be a number.")
	vis.width  = width  or vis.width
	vis.height = height or vis.height
end

-- Metatable
local mtVisualizer = {__index = visualizer}

-- Constructor
local new = function(left, top, width, height, properities)
	local vis = setmetatable({}, mtVisualizer)

	-- Set window properities. (Same for all visualizer types.)
	vis:setWindowPosition(left, top)
	vis:setWindowDimensions(width, height)

	-- Set colors.

	return new
end

----------
return new