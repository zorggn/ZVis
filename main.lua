local width, height
local sounddata, source
local timer, changeTime

local wavescope

function loadFile(file)
	timer = 0.0
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
	changeTime = 2.0 -- seconds
	loadFile('vistestsong.ogg')
end

function love.filedropped(file)
	loadFile(file)
end

function love.update(dt)
	timer = timer + dt
	if timer >= changeTime then
		wavescope.blockRate  = ({1,8,16,32,64,128,256,512,1024})[love.math.random(1,9)]
		wavescope.blockSize  = ({1,8,16,32,64,128,256,512,1024})[love.math.random(1,9)]
		wavescope.blockCount = ({1,8,16,32,64,128,256,512,1024})[love.math.random(1,9)]
		wavescope.blockMode  = ({'signed','unsigned','mirrored'})[love.math.random(1,3)]
		wavescope.renderMode = ({'scan','scroll','sweep'})[love.math.random(1,3)]
		timer = 0.0
	end
	wavescope:update()
end

function love.draw()
	wavescope:draw(0,0)
end