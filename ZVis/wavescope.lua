-- ZVis - WaveScope implementation
-- zorg @ 2016 § ISC

-- Class
local visualizer = {}

-- Getters
visualizer.getWindowPosition   = function(vis)
	return vis.window.left, vis.window.top
	end
visualizer.getWindowDimensions = function(vis)
	return vis.window.width, vis.window.height
	end


-- Setters
visualizer.setWindowPosition   = function(vis, left, top)
	assert(type(left) == 'number' or type(left) == 'nil', "Left must be a number or nil.")
	assert(type(top)  == 'number' or type(top)  == 'nil', "Top must be a number or nil.")
	vis.window.left = left or vis.window.left
	vis.window.top  = top  or vis.window.top
	end
visualizer.setWindowDimensions = function(vis, width, height)
	assert(type(width)  == 'number' or type(width)  == 'nil', "Width must be a number or nil.")
	assert(type(height) == 'number' or type(height) == 'nil', "Height must be a number or nil.")
	vis.window.width  = width  or vis.window.width
	vis.window.height = height or vis.window.height
	end


-- Metatable
local mtVisualizer = {__index = visualizer}

-- Constructor
local new = function(left, top, width, height, properities)
	local vis = setmetatable({}, mtVisualizer)

	-- Set window properities. (Same for all visualizer types.)
	vis.window = {}
	vis:setWindowPosition(left, top)
	vis:setWindowDimensions(width, height)

	-- Set colors.

	return new
end

----------
return new