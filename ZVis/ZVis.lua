-- ZVis - Zorg's Visualizers
-- zorg @ 2016 § ISC

-- Features:
-- - Methods for both realtime and offline/batch/deferred purposes.
-- - Can process chunks, which affect the internal state of the visualizer instance, that will be rendered per-frame.
-- - Can process a complete SoundData, and either render, or export it as an image.*
-- - *: MoodBar, EnvScope, WaveScope, Sonogram, Waterfall, RecurPlot only. (Those that have time as one of their axes.)

local VisualizerTypes = {
	--'LevelMeter',
	--'PhaseMeter',
	--'MoodBar',
	--'Droplet',
	--'EnvScope',
	'WaveScope',
	--'FreqScope',
	--'TelPole',
	--'CometPlot',
	--'DualScope',
	--'Cycles'
	--'Sonogram',
	--'RecurPlot',
	--'Waterfall',
}

local Visualizer = {}

--Visualizer.LevelMeter = require 'LevelMeter' -- 1.0D: A(t)
--Visualizer.LevelMeter = require 'PhaseMeter' -- 1.0D: φ(t)
--Visualizer.MoodBar    = require 'MoodBar'    -- 1.5D: C(t)/t
--Visualizer.Droplet    = require 'Droplet'    -- 1.5D: A(t)/t (polar)
--Visualizer.EnvScope   = require 'EnvScope'   -- 2.0D: A(t)/t
Visualizer.WaveScope  = require 'WaveScope'  -- 2.0D: φ(t)/t
--Visualizer.FreqScope  = require 'FreqScope'  -- 2.0D: A(F(i,t))/F(i)
--Visualizer.TelPole    = require 'TelPole'    -- 2.0D: φ(F(i,t))/F(i)
--Visualizer.CometPlot  = require 'CometPlot'  -- 2.0D: φ(t)/φ'(t)
--Visualizer.DualScope  = require 'DualScope'  -- 2.0D: φ(L(t))/φ(R(t))
--Visualizer.Cycles     = require 'Cycles'     -- 2.0D: φ(Re(F(i,t)))/φ(Im(F(i,t)))
--Visualizer.Sonogram   = require 'Sonogram'   -- 2.5D: A(F(i,t))/F(i)/t
--Visualizer.RecurPlot  = require 'RecurPlot'  -- 2.5D: |φ(i)-φ(j)|/i/j
--Visualizer.Waterfall  = require 'Waterfall'  -- 3.0D: A(F(i,t))/F(i)/t

Visualizer.new = function(VisualizerType, left, top, width, height, ...)
	assert(VisualizerTypes[VisualizerType], ("Visualizer type '%s' not supported."):format(VisualizerType))
	-- Set dimensions and positions to cover the whole screen by default, if any related argument is missing.
	if type(left) == 'nil' or type(top) == 'nil' or type(width) == 'nil' or type(height) == 'nil' then
		left, top = 0, 0
		width, height = love.graphics.getDimensions()
	end
	assert(type(left)      == 'number', ("Visualizer's left position is not a number. (%s)"):format(type(left)))
	assert(type(top)      == 'number', ("Visualizer's top position is not a number. (%s)"):format(type(top)))
	assert(type(width)  == 'number', ("Visualizer's width is not a number. (%s)"):format(type(width)))
	assert(type(height) == 'number', ("Visualizer's height is not a number. (%s)"):format(type(height)))
	return Visualizer[VisualizerType](left, top, width, height, ...)
end

return Visualizer.new