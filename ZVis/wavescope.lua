-- ZVis - WaveScope implementation
-- zorg @ 2016 § ISC

-- References used
--[[
	-- DeliPlayer2 wavescope visualizer
	-- FL studio Wave Candy plugin
	-- http://stackoverflow.com/questions/26452026/how-to-make-waveform-rendering-more-interesting
	-- http://stackoverflow.com/questions/26663494/algorithm-to-draw-waveform-from-audio
	-- http://stackoverflow.com/questions/37554058/fast-display-of-waveform-in-c-c
	-- http://stackoverflow.com/questions/1125666/how-do-you-do-bicubic-or-other-non-linear-interpolation-of-re-sampled
	-- http://yehar.com/blog/wp-content/uploads/2009/08/deip.pdf
	-- http://www.supermegaultragroovy.com/2009/10/06/drawing-waveforms/
--]]

-- Enums
--local blockFunctions = require "blockfunction" -- min, max, avg, rms, rnd
--local channelModes   = require "channelmode"   -- separated, additive, difference, overlay
--local blockMode      = require "blockmode"     -- signed, unsigned, mirrored
--local interpolators  = require "interpolator"  -- none, nearest, linear, cubic, hermite
--local renderModes    = require "rendermode"    -- sweep, scan, scroll

-- Class
local visualizer = {}

-- Getters

-- Setters

-- Callbacks
visualizer.update = function(vis)
	-- Return if we don't have a Source and/or SoundData object.
	if not vis.source   then return end
	if not vis.waveform then return end

	-- Request current time offset from Source.
	local time = vis.source:tell('samples')
	-- Adjust this by means of the channel count.
	time = time * vis.waveform:getChannels()

	-- Determine how many samplepoints elapsed from the last cycle.
	local step = time - vis._lastTime
	-- Wrap it around the adjusted smp count of the waveform.
	step = step % (vis.waveform:getSampleCount() * vis.waveform:getChannels())

	-- If the reported step size is zero, then return to prevent render glitches.
	if step <= 0 then return end

	-- Helper converting elapsed smp-s to seconds.
	local elapsed = step / vis.waveform:getSampleRate() / vis.waveform:getChannels()
	-- Calculate how many blocks to process.
	local count = math.floor(elapsed * vis.blockRate)

	-- Timing fix.
	if count == 0 then return end

	-- Set offset.
	local offset = time

	-- Work on given amount of blocks in one cycle.
	for block = 1, count do

		-- Set up initial smp holding vars.
		local tempL, tempR, tempLi, tempRi
		local tempLa, tempRa, tempLia, tempRia

		if     vis.blockFunction == 'min' then
			tempL, tempR, tempLi, tempRi = math.huge, math.huge, -math.huge, -math.huge
		elseif vis.blockFunction == 'max' then
			tempL, tempR, tempLi, tempRi = 0.0, 0.0, -0.0, -0.0
		elseif vis.blockFunction == 'avg' or vis.blockFunction == 'rms' then
			tempL, tempR, tempLi, tempRi = 0.0, 0.0, 0.0, 0.0
		elseif vis.blockFunction == 'rnd' then
			tempLa, tempRa, tempLia, tempRia = {}, {}, {}, {}
		end

		-- Process samples in a chosen way.
		for smp = 0, vis.blockSize-1 do -- blocksize is 1, so this isn't a loop.

			local tmpL, tmpR

			-- Get samples; if SoundData is mono, duplicate the sample.
			local ofs = offset + (smp) * vis.waveform:getChannels()
			ofs = ofs % 2 == 0 and ofs or ofs+1
				tmpL = vis.waveform:getSample((ofs    ) %
					(vis.waveform:getSampleCount() * vis.waveform:getChannels())) -- scale by step?
			if vis.waveform:getChannels() > 1 then
				tmpR = vis.waveform:getSample((ofs + 1) %
					(vis.waveform:getSampleCount() * vis.waveform:getChannels()))
			else
				tmpR = tmpL
			end

			-- Functions that analyze the smps.
			if vis.blockMode == 'signed' then
				if vis.blockFunction == 'min' then
					tempL  = (tmpL > 0 and tmpL < tempL ) and tmpL or tempL
					tempLi = (tmpL < 0 and tmpL > tempLi) and tmpL or tempLi
					tempR  = (tmpR > 0 and tmpR < tempR ) and tmpR or tempR
					tempRi = (tmpR < 0 and tmpR > tempRi) and tmpR or tempRi
				elseif vis.blockFunction == 'max' then
					tempL  = (tmpL > 0 and tmpL > tempL ) and tmpL or tempL
					tempLi = (tmpL < 0 and tmpL < tempLi) and tmpL or tempLi
					tempR  = (tmpR > 0 and tmpR > tempR ) and tmpR or tempR
					tempRi = (tmpR < 0 and tmpR < tempRi) and tmpR or tempRi
				elseif vis.blockFunction == 'avg' then
					tempL  = tempL  + (tmpL > 0.0 and tmpL or 0.0)
					tempLi = tempLi + (tmpL < 0.0 and tmpL or 0.0)
					tempR  = tempR  + (tmpR > 0.0 and tmpR or 0.0)
					tempRi = tempRi + (tmpR < 0.0 and tmpR or 0.0)
				elseif vis.blockFunction == 'rms' then
					tempL = tempL + tmpL^2
					tempR = tempR + tmpR^2
					--tempLi, tempRi = tempL, tempR -- Better to do this outside the loop.
				elseif vis.blockFunction == 'rnd' then
					if     tmpL > 0.0 then
						tempLa[#tempLa+1]   = tmpL
					elseif tmpL < 0.0 then
						tempLia[#tempLia+1] = tmpL
					else
						tempLa[#tempLa+1]   = 0.0
						tempLia[#tempLia+1] = 0.0
					end
					if     tmpR > 0.0 then
						tempRa[#tempRa+1]   = tmpR
					elseif tmpR < 0.0 then
						tempRia[#tempRia+1] = tmpR
					else
						tempRa[#tempRa+1]   = 0.0
						tempRia[#tempRia+1] = 0.0
					end
				end
			else -- Unsigned and Mirrored mode use these instead.
				if vis.blockFunction == 'min' then
					tempL  = math.abs(tmpL) < math.abs(tempL ) and tmpL or tempL
					tempLi = tempL
					tempR  = math.abs(tmpR) < math.abs(tempR ) and tmpR or tempR
					tempRi = tempR
				elseif vis.blockFunction == 'max' then
					tempL  = math.abs(tmpL) > math.abs(tempL ) and tmpL or tempL
					tempLi = tempL
					tempR  = math.abs(tmpR) > math.abs(tempR ) and tmpR or tempR
					tempRi = tempR
				elseif vis.blockFunction == 'avg' then
					tempL  = tempL + tmpL
					tempR  = tempR + tmpR
					--tempLi, tempRi = tempL, tempR -- Less costly to do this outside the loop.
				elseif vis.blockFunction == 'rms' then
					tempL = tempL + tmpL^2
					tempR = tempR + tmpR^2
					--tempLi, tempRi = tempL, tempR -- Less costly to do this outside the loop.
				elseif vis.blockFunction == 'rnd' then
					tempLa[#tempLa+1] = tmpL
					tempRa[#tempRa+1] = tmpR
				end
			end
		end

		-- Special case for some smp selector block function.
		if vis.blockMode == 'signed' then
			if vis.blockFunction == 'rnd' then
				tempL  = #tempLa  == 0 and 0.0 or tempLa[love.math.random(1,#tempLa)]
				tempLi = #tempLia == 0 and 0.0 or tempLia[love.math.random(1,#tempLia)]
				tempR  = #tempRa  == 0 and 0.0 or tempRa[love.math.random(1,#tempRa)]
				tempRi = #tempRia == 0 and 0.0 or tempRia[love.math.random(1,#tempRia)]
			elseif vis.blockFunction == 'avg' then
				tempL  = tempL  / vis.blockSize
				tempLi = tempLi / vis.blockSize
				tempR  = tempR  / vis.blockSize
				tempRi = tempRi / vis.blockSize
			elseif vis.blockFunction == 'rms' then
				tempL  = math.sqrt(tempL)
				tempLi = -math.sqrt(tempL)
				tempR  = math.sqrt(tempR)
				tempRi = -math.sqrt(tempR)
			end
		else -- Unsigned and Mirrored mode use these instead.
			if vis.blockFunction == 'rnd' then
				tempL  = #tempLa  == 0 and 0.0 or tempLa[love.math.random(1,#tempLa)]
				tempLi = tempL
				tempR  = #tempRa  == 0 and 0.0 or tempRa[love.math.random(1,#tempRa)]
				tempRi = tempR
			elseif vis.blockFunction == 'avg' then
				tempL  = tempL  / vis.blockSize
				tempLi = tempL
				tempR  = tempR  / vis.blockSize
				tempRi = tempR
			elseif vis.blockFunction == 'rms' then
				tempL  = math.sqrt(tempL)
				tempLi = tempL
				tempR  = math.sqrt(tempR)
				tempRi = tempR
			end
		end

		-- Fix for mirrored mode
		if vis.blockMode == 'mirrored' then
			tempLi = -tempLi
			tempRi = -tempRi
		end

		-- Remove illegal values that may have stuck due to no applicable smps.
		tempL  = tempL  >  1.0 and 0.0 or tempL
		tempR  = tempR  >  1.0 and 0.0 or tempR
		tempLi = tempLi < -1.0 and 0.0 or tempLi
		tempRi = tempRi < -1.0 and 0.0 or tempRi

		-- Set values.
		vis.bufferL[vis.bufferPtr] = tempL
		vis.bufferLi[vis.bufferPtr] = tempLi
		vis.bufferR[vis.bufferPtr] = tempR
		vis.bufferRi[vis.bufferPtr] = tempRi

		-- Increment offset
		offset = math.floor(time + (block * (step/count)))

		-- Fix offset.
		offset = offset % (vis.waveform:getSampleCount() * vis.waveform:getChannels())

		-- Increase the buffer pointer for the current smp.
		-- Also handle sweep reversal detection.
		if vis.renderMode == 'scan' then
			vis.bufferPtr = (vis.bufferPtr + (vis._inverseSweep and -1 or 1)) % vis.blockCount
			if (not vis._inverseSweep and vis.bufferPtr == (vis.blockCount - 1)) or
				(   vis._inverseSweep and vis.bufferPtr == 0) then
				vis._inverseSweep = not vis._inverseSweep
			end
		else
			vis.bufferPtr = (vis.bufferPtr + 1) % vis.blockCount
		end
	end

	-- Save for next cycle.
	vis._lastTime = time
end

visualizer.draw = function(vis,x,y)
	love.graphics.push()
	love.graphics.translate(x, y)

	love.graphics.setColor(255,255,255)
	love.graphics.print(tostring(vis._lastTime), 0, 0)
	if vis.waveform then
		love.graphics.print(tostring(vis.waveform:getSampleCount()*vis.waveform:getChannels()), 0, 12)
		love.graphics.rectangle('fill',vis._lastTime/(vis.waveform:getSampleCount()*vis.waveform:getChannels()),1,1,1)
	end

	--love.graphics.print(tostring(vis.bufferL[vis.bufferPtr]), 0, 0)
	--love.graphics.print(tostring(vis.bufferLi[vis.bufferPtr]), 0, 12)
	--love.graphics.print(tostring(vis.bufferR[vis.bufferPtr]), 0, 24)
	--love.graphics.print(tostring(vis.bufferRi[vis.bufferPtr]), 0, 36)

	--[=[

	for smp = 0, vis.blockCount-1 do
		local y = (720) + ((smp*12) - (12*vis.bufferPtr))
		if vis.bufferL[smp]  > 0 then love.graphics.setColor(255,63,63) else love.graphics.setColor(127,127,127) end
		love.graphics.print(("%.4f"):format(vis.bufferL[smp]),  100, y)
		if vis.bufferLi[smp] < 0 then love.graphics.setColor(63,63,255) else love.graphics.setColor(127,127,127) end
		love.graphics.print(("%.4f"):format(vis.bufferLi[smp]), 150, y)
		if vis.bufferR[smp]  > 0 then love.graphics.setColor(255,63,63) else love.graphics.setColor(127,127,127) end
		love.graphics.print(("%.4f"):format(vis.bufferR[smp]),  250, y)
		if vis.bufferRi[smp] < 0 then love.graphics.setColor(63,63,255) else love.graphics.setColor(127,127,127) end
		love.graphics.print(("%.4f"):format(vis.bufferRi[smp]), 300, y)
	end

	--]=]

	local w,h = vis.windowWidth/vis.blockCount, vis.windowHeight/4

	love.graphics.setColor(127,127,127,127)
	love.graphics.line(0,h,1280,h)
	love.graphics.line(0,3*h,1280,3*h)

	---[[
	for smp = 0, vis.blockCount-1 do

		if vis.renderMode ~= 'scroll' then
			if vis.blockMode == 'mirrored' then
				love.graphics.setColor(255,63,255,127)
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferL[(smp)% vis.blockCount])
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferLi[(smp)% vis.blockCount])
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferR[(smp)% vis.blockCount])
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferRi[(smp)% vis.blockCount])
			else
				love.graphics.setColor(255,63,63,127)
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferL[(smp)% vis.blockCount])
				love.graphics.setColor(63,63,255,127)
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferLi[(smp)% vis.blockCount])

				love.graphics.setColor(255,63,63,127)
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferR[(smp)% vis.blockCount])
				love.graphics.setColor(63,63,255,127)
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferRi[(smp)% vis.blockCount])
			end
		else 
			if vis.blockMode == 'mirrored' then
				love.graphics.setColor(255,63,255,127)
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferL[(vis.bufferPtr + smp)% vis.blockCount])
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferLi[(vis.bufferPtr + smp)% vis.blockCount])
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferR[(vis.bufferPtr + smp)% vis.blockCount])
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferRi[(vis.bufferPtr + smp)% vis.blockCount])
			else
				love.graphics.setColor(255,63,63,127)
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferL[(vis.bufferPtr + smp)% vis.blockCount])
				love.graphics.setColor(63,63,255,127)
				love.graphics.rectangle('fill',smp*w, h,   w, -h*vis.bufferLi[(vis.bufferPtr + smp)% vis.blockCount])

				love.graphics.setColor(255,63,63,127)
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferR[(vis.bufferPtr + smp)% vis.blockCount])
				love.graphics.setColor(63,63,255,127)
				love.graphics.rectangle('fill',smp*w, 3*h, w, -h*vis.bufferRi[(vis.bufferPtr + smp)% vis.blockCount])
			end
		end

	end
	--]]

	love.graphics.setColor(255,255,255)
	love.graphics.print(tostring(love.graphics.getStats()['drawcalls']), 0, 24)

	love.graphics.pop()
end

-- Metatable
local mtVisualizer = {__index = visualizer}

-- Constructor
local new = function()
	local vis = setmetatable({}, mtVisualizer)

	-- Processing related ("hidden")
	vis._lastTime = 0         -- in smp-s
	vis._inverseSweep = false -- if true, current cycle goes in reverse
	vis._ = nil

	-- Visualization data related
	vis.bufferPtr = 0
	vis.bufferL   = {}
	vis.bufferR   = {}
	vis.bufferLi  = {}
	vis.bufferRi  = {}

	-- Waveform and timing related
	vis.source   = nil
	vis.waveform = nil

	-- Data windowing related
	vis.blockRate  = 1000 --1024*10 -- unit/sec
	vis.blockSize  = 1--64      -- smp/unit
	vis.blockCount = 1000--1024    -- smp

	-- Initialize buffers
	for i=0, vis.blockCount-1 do
		vis.bufferL[i]  = 0.0
		vis.bufferR[i]  = 0.0
		vis.bufferLi[i] = 0.0
		vis.bufferRi[i] = 0.0
	end

	-- Data block value related
	vis.blockFunction = 'avg'
	vis.blockMode     = 'signed'

	-- Channel related
	vis.channelMode = 'separated'

	-- GUI window related
	vis.blockScale    = 1.0 -- px/unit
	vis.windowWidth   = 1024
	vis.windowHeight  = 720
	vis.waveformSpacing = 0 -- distance in px between each block
	vis.waveformTrail = true -- draws lines between consecutive points
	vis.waveformStar  = true -- draws lines perpendicular to the time axis, from DC* to points
	vis.pinchEnds     = false

	-- Interpolation related
	vis.interpolation = 'none'
	vis.circleSmps    = false -- if true, draw circles over true samplepoint locations when zoomed in

	-- Render related
	vis.renderMode   = 'scroll'
	vis.renderInvert = false -- if true, time-axis directions are mirrored.
	vis.phaseInvert  = false -- if true, value-axis directions are mirrored within channels.
	vis.channelOrder = {1,2} -- TODO: Implement this later for custom channel counts... or not.

	return vis
end

----------
return new