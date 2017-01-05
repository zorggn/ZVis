-- ZVis - WaveScope implementation
-- zorg @ 2016 § ISC

-- Constants
local colorModeGetterWrapper = {"get", "", "Color"}
local colorModeSetterWrapper = {"set", "", "Color"} -- Thx, MasterGeek. :3

-- Enums
local colorType = {
	['background'] = true,
	['baseline']   = true,
	['line'] = true, ['line+'] = true, ['line-'] = true, ['line|'] = true,
	['fill'] = true, ['fill+'] = true, ['fill-'] = true, ['fill|'] = true,
}
local colorMode = {
	['simple']   = true,
	['gradient'] = true,
	['spectral'] = true,
	['weighted'] = true,
	['shader']   = true,
}
local defaultColors = {
	['background'] = {0,0,0,0},
	['baseline']   = {.25,.25,.25,1},
	['line'] = {0,.75,0,1},  ['line+'] = {.75,0,0,1},  ['line-'] = {0,0,.75,1},  ['line|'] = {.5,0,.5,1},
	['fill'] = {0,.75,0,.5}, ['fill+'] = {.75,0,0,.5}, ['fill-'] = {0,0,.75,.5}, ['fill|'] = {.5,0,.5,.5},
}

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