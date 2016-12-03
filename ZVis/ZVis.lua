-- ZVis - Zorg's Visualizers
-- zorg @ 2016 § ISC

-- Features:
-- - Methods for both realtime and offline/batch/deferred purposes.
-- - Can process chunks, which affect the internal state of the visualizer instance, that will be rendered per-frame.
-- - Can process a complete SoundData, and either render, or export it as an image.*
-- - *: WaveScope, Sonogram, Waterfall, MoodBar RecurPlot only. (Those that have time as one of their axes.)

local VisualizerTypes = {
	--'LevelMeter',
	'WaveScope',
	--'FreqScope',
	--'Sonogram',
	--'Waterfall',
	--'MoodBar',
	--'CometPlot',
	--'RecurPlot',
	--'Droplets',
	--'DualScope',
}

local Visualizer = {}

--Visualizer.LevelMeter = require 'LevelMeter' -- 1D: A(t)
Visualizer.WaveScope  = require 'WaveScope'  -- 2D: φ(t)/t         (a.k.a. Oscilloscope / Waveform Analyzer)
--Visualizer.FreqScope  = require 'FreqScope'  -- 2D: A(F(t))/F(t)   (a.k.a. Spectroscope / Spectrum Analyzer)
--Visualizer.Sonogram   = require 'Sonogram'   -- 2D:         F(t)/t (a.k.a. Spectrogram)
--Visualizer.Waterfall  = require 'Waterfall'  -- 3D: A(F(t))/F(t)/t
--Visualizer.MoodBar    = require 'MoodBar'    -- 1D: A(F(t))/t      (a.k.a. Rainbow)
--Visualizer.CometPlot  = require 'CometPlot'  -- 2D: φ(t)/φ'(t)     (a.k.a. Phasor)
--Visualizer.RecurPlot  = require 'RecurPlot'  -- 2D: φ(t)/T(φ(t))
--Visualizer.Droplets   = require 'Droplet'    -- 0D: r(A(t))
--Visualizer.DualScope  = require 'DualScope'  -- 2D: φL(t)/φR(t)    (a.k.a. Stereoscope)

Visualizer.new = function(VisualizerType, x, y, width, height, ...)
	assert(VisualizerTypes[VisualizerType], ("Visualizer type '%s' not supported!"):format(VisualizerType))
	return Visualizer[VisualizerType](x, y, width, height, ...)
end

return Visualizer.new