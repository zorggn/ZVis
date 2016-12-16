# ZVis

A visualization library for the Löve framework.

Supports 0.10.2 and the yet-unreleased 0.11 nightlies.

# Status

	v0.0.0 - May work, but not "officially" released.

# Supported visualization types

Note that these names were chosen to hopefully minimize the gigantic overlap that exists in music/audio/dsp terminology.

Fractional dimensional values mean that one dimension is "folded", i.e. it's not represented by a spatial axis.

Rarity is a somewhat ad-hoc value, relative to my own experiences with music players and DAW software, whether or not they included a specific type of visualizer.

## Level Meter

	1 Dimensional: A(t)
		A(t): Signal amplitude at a moment in time.
	Common

	One of the most basic types of visualizers.

## Phase Meter

	1 Dimensional: φ(t)
		φ(t): Signal phase at a moment in time.
	Rare

	It's more common to use Wave Scope equivalents if one wants to see the phase of the signal.

## Mood Bar / Rainbow

	1.5 Dimensional: C(t)/t
		C(t): Spectral centroid of signal at a moment in time.
		t: Time.
	Uncommon

	The first dimension is folded into the properities (e.g. color) of the data points.
	The music player Amarok supports this type of visualization.

## Droplet

	1.5 Dimensional: A(t)/t
		A(t): Signal amplitude at a moment in time.
		t: Time.
	Uncommon

	The first dimension is folded into the properities (e.g. color) of the data points, and that the second dimension is actually the distance from a specified "center", since this is actually a polar visualizer.
	The DOS module player "XTC-PLAY" includes this type of visualization.

## Envelope Scope

	2 Dimensional: A(t)/t
		A(t): Signal amplitude at a moment in time.
		t: Time.
	Rare

	It's more common to see either Wave Scopes or Level Meters instead.

## Wave Scope (Oscilloscope / Waveform Analyzer)

	2 Dimensional: φ(t)/t
		φ(t): Signal phase at a moment in time.
		t: Time.
	Common

	One of the most basic types of visualizers.

## Freq Scope (Spectroscope / Spectrum Analyzer)

	2 Dimensional: A(F(i,t))/F(i)
		A(F(i,t)): Amplitude of frequency bins/bands at a moment in time.
		F(i): Frequency bins/bands.
	Common

	One of the most basic types of visualizers.

## Tel. Pole

	2 Dimensional: φ(F(i,t))/F(i)
		φ(F(i,t)): Phase of frequency bins/bands at a moment in time.
		F(i): Frequency bins/bands.
	Rare

	Freq Scope equivalents either discard the complex values, or actually do a Real-only FFT to get the frequency data used in them; this one shows both.

## Comet Plot (Phasor)

	2 Dimensional: φ(t)/φ'(t)
		φ(t): Signal phase at a moment in time.
		φ'(t): First derivative (slope) of signal phase at a moment in time.
	Uncommon

## Dual Scope (Stereoscope)

	2 Dimensional: φ(L(t))/φ(R(t))
		φ(L(t)): Signal phase of left channel at a moment in time.
		φ(R(t)): Signal phase of right channel at a moment in time.
	Common

## Cycles

	2 Dimensional: φ(Re(F(i,t)))/φ(Im(F(i,t)))
		φ(Re(F(i,t))): Phase of the real part of frequency bins/bands at a moment in time.
		φ(Im(F(i,t))): Phase of the imaginary part of frequency bins/bands at a moment in time.
	Rare

	I personally never seen this type of visualization used in either music players or DAWs before, though it is known as an example of how a more complex waveform can be built up from multiple sine waves; this is just the inverse of that.

## Sonogram (Spectrogram)

	2.5 Dimensional: A(F(i,t))/F(i)/t
		A(F(i,t)): Amplitude of frequency bins/bands at a moment in time.
		F(i): Frequency bins/bands.
		t: Time.
	Uncommon

	The first dimension is folded into the properities (e.g. color) of the data points.

## Recurrence Plot

	2.5 Dimensional: |φ(i)-φ(j)|/i/j
		|φ(i)-φ(j)|: Distance of the ith samplepoint's phase value from the jth samplepoint's.
		i: The first index of the samples in a chunk of samplepoints.
		j: The second index of the samples in a chunk of samplepoints.
	Rare

	The first dimension is folded into the properities (e.g. color) of the data points.

## Waterfall

	3 Dimensional: A(F(i,t))/F(i)/t
		A(F(i,t)): Amplitude of frequency bins/bands at a moment in time.
		F(i): Frequency bins/bands.
		t: Time.
	Uncommon

# License

ISC License