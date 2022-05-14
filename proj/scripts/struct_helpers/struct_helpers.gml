/// @func struct_copy(source, dest)
function struct_copy (_src, _dest)
{
	var _vars = variable_struct_get_names(_src);
	for (var i=0; i<array_length(_vars); i++)
	{
		_dest[$ _vars[i]] = _src[$ _vars[i]];
	}
}

/// @func struct_duplicate(source)
function struct_duplicate (_src)
{
	var _struct = {};
	var _vars = variable_struct_get_names(_src);
	for (var i=0; i<array_length(_vars); i++)
	{
		_struct[$ _vars[i]] = _src[$ _vars[i]];
	}
	
	return _struct;
}

/// @func struct_fetch(struct, key, default)
function struct_fetch (_struct, _key, _default)
{
	var _value = _struct[$ _key];
	return _value != undefined ? _value : _default;
}