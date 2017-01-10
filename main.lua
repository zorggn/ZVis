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

local ffi = require "ffi"
local liblove = ffi.os == "Windows" and ffi.load("love") or ffi.C

ffi.cdef[[

	typedef struct {
		unsigned char major;
		unsigned char minor;
		unsigned char patch;
	} PHYSFS_Version;

	void PHYSFS_getLinkedVersion(PHYSFS_Version * ver);

	const char * PHYSFS_getLastError(void);

	int PHYSFS_mount(
		const char * newDir, const char * mountPoint, int appendToPath
	);

	int PHYSFS_removeFromSearchPath(const char * oldDir);
	int PHYSFS_unmount(const char * oldDir);
]]

-- TODO: If cdef dies like this due to either rFSP or unmnt missing, then
--       we need an init funtion that cdef-s depending on the version;
--       also modify Fsys.unmount to move the versioncheck out into init.

local Fsys = {}

Fsys.mount = function(path, mountPoint, appendToPath)
	local result = liblove.PHYSFS_mount(path, mountPoint, appendToPath)

	if result ~= 0 then 
		return true
	else
		return false, liblove.PHYSFS_getLastError()
	end
end

Fsys.unmount = function(path)
	local result
	local version = ffi.new('PHYSFS_Version[1]') -- may be *[1] instead.
	liblove.PHYSFS_getLinkedVersion(version)

	-- Depends on what Löve was built with.
	if version[0].major >= 2 and version[0].minor >= 1 then
		result = liblove.PHYSFS_unmount(path)
	else
		result = liblove.PHYSFS_removeFromSearchPath(path)
	end

	if result ~= 0 then 
		return true
	else
		return false, liblove.PHYSFS_getLastError()
	end
end

-------------------------------------------------------------------
local windowTitle = "ZVis - Test App"

local pathList = {}
local current = 0
local value = 0

function love.load()
	if love.filesystem.isFile('playlist.lua') then
		pathList = love.filesystem.load('playlist.lua')()
		for i,v in ipairs(pathList) do print(i,v) end
	end
	if #pathList>0 then
		current = 1
		loadFile(pathList[current])
	end
end

function love.quit()
	local s = "return {[["
	s = s .. table.concat(pathList,']],[[')
	s = s .. "]]}"
	love.filesystem.write('playlist.lua', s)
end

function love.update(dt)
	if not source then return end
	if not source:isPlaying() then
		current = ((current + 0) % #pathList) + 1
		loadFile(pathList[current])
	else
		value = sounddata:getSample(math.floor(source:tell('samples')*sounddata:getChannels()))
	end
end

function love.keypressed(k,s)
	if s == 'left'  then current = ((current - 2) % #pathList) + 1 end
	if s == 'right' then current = ((current + 0) % #pathList) + 1 end
	if s == 'left' or s == 'right' then
		loadFile(pathList[current])
	end
end

function love.draw()
	love.graphics.setLineWidth(5)
	love.graphics.line(0,360,512,360+value*360,1024,360)
end

function love.filedropped(file)
	pathList[#pathList+1] = file:getFilename()
	current = #pathList
	loadFile(file)
end

local mountPoint = '_temp'
function loadFile(file)
	-- Support both file objects and paths.
	local path,name

	if type(file) == 'string' then
		print(file)
		local index = file:match'^.*()/' --apparently faster than string.find(file, "/[^/]*$")
		if not index then index = file:match'^.*()\\' end
		path,name = file:sub(1,index), file:sub(index+1,nil)
		Fsys.mount(path, mountPoint, false)
		file = love.filesystem.newFile(mountPoint .. '/' .. name)
		Fsys.unmount(mountPoint) -- is this needed though? Wouldn't löve's own unmount work?
	else
		path = file:getFilename()
		name = ''
	end

	-- Handy thing to see what we're playing.
	love.window.setTitle(windowTitle .. " | " .. path .. name)

	-- Stop playing source(s).
	love.audio.stop()

	-- Try to free up memory.
	if sounddata or source then
		sounddata, source = nil, nil
		collectgarbage("collect"); collectgarbage("collect")
	end

	-- Load in the new file.
	sounddata = love.sound.newSoundData(file)
	source    = love.audio.newSource(sounddata)

	-- Play the track.
	source:setLooping(false)
	source:setPitch(1.0)
	source:play()
end