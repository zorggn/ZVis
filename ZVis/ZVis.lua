-- ZVis - Zorg's Visualizers
-- zorg @ 2016 § ISC

-- Features:
-- - Methods for both realtime and offline/batch/deferred purposes.
-- - Can process chunks, which affect the internal state of the visualizer instance, that will be rendered per-frame.
-- - Can process a complete SoundData, and either render, or export it as an image.*
-- - *: MoodBar, EnvScope, WaveScope, Sonogram, Waterfall, RecurPlot only. (Those that have time as one of their axes.)

-- Constants
local fmtStr2x = '%s%s'

-- Enums
local visualizerType = {
	--['LevelMeter'] = true,
	--['PhaseMeter'] = true,
	--['MoodBar']    = true,
	--['Droplet']    = true,
	--['EnvScope']   = true,
	['WaveScope']  = true,
	--['FreqScope']  = true,
	--['TelPole']    = true,
	--['CometPlot']  = true,
	--['DualScope']  = true,
	--['Cycles]      = true,
	--['Sonogram']   = true,
	--['RecurPlot']  = true,
	--['Waterfall']  = true,
}

-- Class
local visualizer = {}

-- Members
--visualizer.LevelMeter = require 'LevelMeter' -- 1.0D: A(t)
--visualizer.LevelMeter = require 'PhaseMeter' -- 1.0D: φ(t)
--visualizer.MoodBar    = require 'MoodBar'    -- 1.5D: C(t)/t
--visualizer.Droplet    = require 'Droplet'    -- 1.5D: A(t)/t (polar)
--visualizer.EnvScope   = require 'EnvScope'   -- 2.0D: A(t)/t
visualizer.WaveScope  = require 'WaveScope'  -- 2.0D: φ(t)/t
--visualizer.FreqScope  = require 'FreqScope'  -- 2.0D: A(F(i,t))/F(i)
--visualizer.TelPole    = require 'TelPole'    -- 2.0D: φ(F(i,t))/F(i)
--visualizer.CometPlot  = require 'CometPlot'  -- 2.0D: φ(t)/φ'(t)
--visualizer.DualScope  = require 'DualScope'  -- 2.0D: φ(L(t))/φ(R(t))
--visualizer.Cycles     = require 'Cycles'     -- 2.0D: φ(Re(F(i,t)))/φ(Im(F(i,t)))
--visualizer.Sonogram   = require 'Sonogram'   -- 2.5D: A(F(i,t))/F(i)/t
--visualizer.RecurPlot  = require 'RecurPlot'  -- 2.5D: |φ(i)-φ(j)|/i/j
--visualizer.Waterfall  = require 'Waterfall'  -- 3.0D: A(F(i,t))/F(i)/t

-- Constructor
local new = function(vtype, left, top, width, height, ...)
	assert(visualizerType[vtype], ("Visualizer type '%s' not supported."):format(vtype))
	-- Set dimensions and positions to cover the whole screen by default, if any related argument is missing.
	if type(left) == 'nil' or type(top) == 'nil' or type(width) == 'nil' or type(height) == 'nil' then
		left, top = 0, 0
		width, height = love.graphics.getDimensions()
	end
	assert(type(left)   == 'number', ("Left position is not a number. (%s)"):format(type(left)))
	assert(type(top)    == 'number', ("Top position is not a number. (%s)"):format(type(top)))
	assert(type(width)  == 'number', ("Width is not a number. (%s)"):format(type(width)))
	assert(type(height) == 'number', ("Height is not a number. (%s)"):format(type(height)))
	return visualizer[vtype](left, top, width, height, ...)
end

-- Specialized Constructors
for k,v in pairs(visualizerType) do
	visualizer[fmtStr2x:format(new,v)] = function(...) return visualizer.new(v,...) end
end

-- Metatable
local mtVisualizer = {__call = function(_,...) return new(...) end}

-----------------
return setmetatable(visualizer, mtVisualizer)