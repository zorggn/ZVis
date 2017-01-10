--[==[
-- Example visualizer program
-- Drop a file on the window to play it!

-- Waveform data and timing.
local sounddata, source

-- Used to change visualizers, since this would be a showcase.
local timer, changeTime

-- The visualizer.
local wavescope

function loadFile(file)
	-- Support both file objects and paths.
	if type(file) == 'string' then
		file = love.filesystem.newFile(file)
	end

	-- Handy thing to see what we're playing.
	love.window.setTitle(file:getFilename())

	-- Each new file should reset the current visualizer's time remaining.
	timer = 0.0

	-- Stop playing source(s).
	love.audio.stop()

	-- Try to free up memory.
	sounddata, source = nil, nil
	collectgarbage("collect"); collectgarbage("collect")

	-- Load in the new file.
	sounddata = love.sound.newSoundData(file)
	source    = love.audio.newSource(sounddata)

	-- Create a visualizer, and set it up.
	wavescope = require('ZVis.wavescope')()
	wavescope.source = source
	wavescope.waveform = sounddata
	wavescope.bufferPtr = 0

	-- Play the track.
	source:setLooping(true)
	source:setPitch(1.0)
	source:play()
end

function love.load()
	-- How fast visualizers are swapped.
	changeTime = 2.0 -- seconds

	-- Load example file.
	loadFile('vistestsong.ogg')
end

function love.filedropped(file)
	loadFile(file)
end

function love.update(dt)
	timer = timer + dt
	if timer >= changeTime then
		-- Let's have a neat list of them.
		--wavescope.blockRate  = ({1,8,16,32,64,128,256,512,1024})[love.math.random(1,9)]
		--wavescope.blockSize  = ({1,8,16,32,64,128,256,512,1024})[love.math.random(1,9)]
		--wavescope.blockCount = ({1,8,16,32,64,128,256,512,1024})[love.math.random(1,9)]
		--wavescope.blockMode  = ({'signed','unsigned','mirrored'})[love.math.random(1,3)]
		--wavescope.renderMode = ({'scan','scroll','sweep'})[love.math.random(1,3)]
		timer = 0.0
	end
	wavescope:update()
end

function love.draw()
	wavescope:draw(0,0)
end
--]==]
end