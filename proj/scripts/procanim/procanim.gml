/*
	Various oscillating & helping functions for procedural animation
*/
gml_pragma("forceinline");

// Returns oscillating values between -1 and 1
function osc_sin (_freq)
{
	return sin(current_time * 0.002 * pi * _freq);
}
function osc_cos (_freq)
{
	return cos(current_time * 0.002 * pi * _freq);
}

// Same as above except the value goes from 0 to 1
function osc_sin_n (_freq)
{
	return sin(current_time * 0.002 * pi * _freq) * 0.5 + 0.5;
}
function osc_cos_n(_freq)
{
	return cos(current_time * 0.002 * pi * _freq) * 0.5 + 0.5;
}

// Same as above except you pass your own time/tick values
function osc_sin_adv (_t, _unit)
{
	return sin((_t/_unit) * 2 * pi);
}
function osc_cos_adv (_t, _unit)
{
	return cos((_t/_unit) * 2 * pi);
}

// Same as above except the value goes from _a to _b
function osc_sin_lerp (_freq, _a, _b)
{
	return lerp(_a, _b, sin(current_time * 0.002 * pi * _freq) * 0.5 + 0.5);
}
function osc_cos_lerp(_freq, _a, _b)
{
	return lerp(_a, _b, cos(current_time * 0.002 * pi * _freq) * 0.5 + 0.5);
}

// Applies "weight" to given value representing linear curve that is in 0..1 range (useful for lerp() animation)
/// @func interp_weight(x, weightstart, weightend)
function interp_weight (_x, _wstart, _wend)
{
	return power(1.0 - power(1.0 - _x, _wend), _wstart);
}

// Calculates and returns "weighted" interpolation factor value in 0..1 from given value and maximum value (useful for lerp() animation)
/// @func calc_interp_weight(x, xmax, weightstart, weightend)
function calc_interp_weight (_x, _xmax, _wstart, _wend)
{
	return power(1.0 - power(1.0 - clamp(_x/_xmax, 0, 1), _wend), _wstart);
}
