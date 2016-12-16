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

Visualizer.new = function(VisualizerType, x, y, width, height, ...)
	assert(VisualizerTypes[VisualizerType], ("Visualizer type '%s' not supported!"):format(VisualizerType))
	return Visualizer[VisualizerType](x, y, width, height, ...)
end

return Visualizer.new