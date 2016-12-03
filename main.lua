local width, height
local sounddata, source

local wavescope

function loadFile(file)
	if type(file) == 'string' then
		file = love.filesystem.newFile(file)
	end
	love.window.setTitle(file:getFilename())
	if sounddata then sounddata = nil end
	if source and source:isPlaying() then source:stop() source = nil end
	collectgarbage("collect")
	sounddata = love.sound.newSoundData(file)
	source    = love.audio.newSource(sounddata)
	wavescope = require('ZVis.wavescope')()
	wavescope.source = source
	wavescope.waveform = sounddata
	wavescope.bufferPtr = 0
	source:setLooping(true)
	source:setPitch(1.0)
	source:play()
end

function love.load()
	width, height = love.graphics.getDimensions()
	loadFile('vistestsong.ogg')
end

function love.filedropped(file)
	loadFile(file)
end

function love.update(dt)
	wavescope:update()
end

function love.draw()
	wavescope:draw(0,0)
end