/// @description delicious.
var _ww = window_get_width(), _wh = window_get_height();
/*
#region Draw visualizations
if (!surface_exists(visualSurf))
	visualSurf = surface_create(256, dspBuffSize);
if (!surface_exists(visualSurfPrev))
	visualSurfPrev = surface_create(256, dspBuffSize);

surface_copy(visualSurfPrev, 0, 0, visualSurf);

surface_set_target(visualSurf);
// scroll
draw_surface(visualSurfPrev, 1, 0);
surface_reset_target();


// Set surface values from buffer
if (dspBuffPlaying != undefined)
{
	buffer_get_surface(buffSurf, visualSurf, 0);
	for (var i=0; i<dspBuffSize; i++)
	{
		var _v = buffer_peek(dspBuffPlaying, i, buffer_u8);
		// plot points
		buffer_seek(buffSurf, buffer_seek_start, 256 * 4 * i);
		buffer_write(buffSurf, buffer_u8, _v);
		buffer_write(buffSurf, buffer_u8, _v);
		buffer_write(buffSurf, buffer_u8, _v);
		buffer_write(buffSurf, buffer_u8, 0xFF);
	}
	buffer_set_surface(buffSurf, visualSurf, 0);
	draw_surface_stretched(visualSurf, 0, 0, _ww, _wh);
}
#endregion
*/
// Draw Debug UI
draw_set_font(fntDefault);

// Draw loaded program
var _prg = "", _tokenstr = "";
for (var i=0; i<array_length(glitch.program); i++)
{
	var _token = glitch.program[i],
		_type = _token[0];
	switch (_type)
	{
		case eTOKEN.NUM:
			if (_token[2]) // hex?
				_tokenstr = "0x" + __tohex(_token[1]);
			else
				_tokenstr = string(_token[1]);
			break;
		
		case eTOKEN.VAR:
			_tokenstr = string(_token[1]);
			break;
		
		default:
			_tokenstr = global.glitchTokensName[_type];
			break;
	}
	_prg += _tokenstr;
	
	//if ((i+1) % 11 == 0)
	//	_prg += "\n";
	//else
	_prg += " ";
}
if (_prg == "") _prg = "<NONE>";

var _xx = _ww - 8 - string_width(_prg) * 2;
draw_set_halign(0); draw_set_valign(0);
draw_rectangle_colour(_xx - 6, 2, _ww-2, 2 + string_height(_prg) * 2, c_black, c_black, c_black, c_black, false);
draw_text_transformed_color(_xx, 8, _prg, 2, 2, 0, c_white, c_white, c_white, c_white, 1);

// Draw stack
//var _stack_info = "TOSP: " + string(glitch.tosp) + " | T: " + string(glitch.t) + "\n";
var _stack_info = "TOSP: " + string(0) + " | T: " + string(glitch.t) + "\n";
draw_set_halign(0); draw_set_valign(1);
draw_text_transformed_color(8, 8, _stack_info, 2, 2, 0, c_white, c_white, c_white, c_white, 1);
/*
var _x = 8, _y = 32,
	_cell_sz = 32;
draw_set_halign(1); draw_set_valign(1);
var _dx = _x;
for (var i=0; i<=0xFF; i++)
{
	var _v = buffer_peek(glitch.stack, i, buffer_u32), _c = merge_color(0, c_white, _v/0xFFFFFFFF);
	//draw_rectangle_color(_dx, _y, _dx+_cell_sz, _y+_cell_sz, _c, _c, _c, _c, false);
	draw_sprite_stretched_ext(sprWhite, 0, _dx, _y, _cell_sz, _cell_sz, _c, 1);
	draw_text_transformed_color(_dx+(_cell_sz>>1), _y+(_cell_sz>>1), string(_v), 0.5, 0.5, 0, c_blue, c_blue, c_blue, c_blue, 1);
	_dx += _cell_sz;
	if ((i+1) % 16 == 0)
	{
		_dx = _x;
		_y += _cell_sz;
	}
}

draw_sprite_stretched_ext(sprWhite, 0, _x + _cell_sz * 20, osc_cos_lerp(1, _y, _y+64), _cell_sz, _cell_sz, c_white, 1);

// Draw buffer
var _x = 8, _y = 32 + _cell_sz*16,
	_sample_margin = 512 / dspBuffSize,
	_h = 64;
draw_primitive_begin(pr_linestrip);
for (var i=0; i<dspBuffSize; i++)
{
	var _v = buffer_peek(dspBuffPlaying, i, buffer_u8);
	draw_vertex_colour(_x, _y + _h - (_v/0xFF) * _h, c_red, 1);
	_x += _sample_margin;
}
draw_primitive_end();
*/
