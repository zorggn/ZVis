-- FFT implementation
-- zorg @ 2016 § ISC

-- References used
--[[
	-- https://rosettacode.org/wiki/Fast_Fourier_transform#Lua
--]]

local complex = require 'complex'

-- Cooley–Tukey FFT (in-place, divide-and-conquer)
-- Higher memory requirements and redundancy although more intuitive
function fft(vect)
	local n = #vect
	if n <= 1 then return vect end

	-- divide  
	local odd, even = {}, {}
	for i = 1, n, 2 do
		odd[#odd + 1]   = vect[i]
		even[#even + 1] = vect[i + 1]
	end

	-- conquer
	fft(even);
	fft(odd);

	-- combine
	for k = 1, n / 2 do
		local t = even[k] * complex.expi(-2.0 * math.pi * (k - 1) / n)
		vect[k] = odd[k] + t;
		vect[k + n / 2] = odd[k] - t;
	end

	return vect
end

function toComplex(vectr)
	vect = {}
	for i, r in ipairs(vectr) do
		vect[i] = complex.new(r)
	end
	return vect
end