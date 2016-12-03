-- Complex number implementation
-- zorg @ 2016 § ISC

-- References used
--[[
	-- https://rosettacode.org/wiki/Fast_Fourier_transform#Lua
--]]

-- operations on complex number
local complex = {__mt={} }
 
function complex.new (r, i) 
	local new={r=r or 0, i=i or 0} 
	setmetatable(new,complex.__mt)
	return new
end
 
function complex.__mt.__add (c1, c2)
	return complex.new(c1.r + c2.r, c1.i + c2.i)
end
 
function complex.__mt.__sub (c1, c2)
	return complex.new(c1.r - c2.r, c1.i - c2.i)
end
 
function complex.__mt.__mul (c1, c2)
	return complex.new(c1.r*c2.r - c1.i*c2.i,
		c1.r*c2.i + c1.i*c2.r)
end
 
function complex.expi (i)
	return complex.new(math.cos(i),math.sin(i))
end
 
function complex.__mt.__tostring(c)
	return "("..c.r..","..c.i..")"
end

return complex