/// @description delicious.
var _ww = window_get_width(), _wh = window_get_height();

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
		var _v = buffer_peek(dspBuffPlaying, i, buffer_u8) / 255,
			_col = make_color_hsv((251/360*255) + ((337-251)/360*255) * _v, (74*2.55) + ((68-74)*2.55) * _v, (9*2.55) + ((76-9)*2.55) * _v);
		// plot points
		buffer_seek(buffSurf, buffer_seek_start, 256 * 4 * i);
		buffer_write(buffSurf, buffer_u8, color_get_red(_col)); // R
		buffer_write(buffSurf, buffer_u8, color_get_green(_col)); // G
		buffer_write(buffSurf, buffer_u8, color_get_blue(_col)); // B
		buffer_write(buffSurf, buffer_u8, 0xFF); // A
	}
	buffer_set_surface(buffSurf, visualSurf, 0);
	draw_surface_stretched(visualSurf, 0, 0, _ww, _wh);
}
#endregion

// Draw Debug UI
draw_set_font(fntDefault);

// Draw buffer
var _x = 0, _y = 0,
	_sample_margin = _ww / dspBuffSize,
	_thick = 4, _h = _wh;

for (var i=0; i<dspBuffSize-1; i++)
{
	var _v = buffer_peek(dspBuffPlaying, i, buffer_u8), _v2 = buffer_peek(dspBuffPlaying, i+1, buffer_u8);
	draw_line_width_color(	_x+_thick, _y + _h - (_v / 0xFF) * _h + _thick,
							_x+_sample_margin, _y + _h - (_v2 / 0xFF) * _h, _thick, c_black, c_black);
	draw_line_width_color(	_x, _y + _h - (_v / 0xFF) * _h,
							_x+_sample_margin, _y + _h - (_v2 / 0xFF) * _h, _thick, #FFDD00, #FFDD00);
	_x += _sample_margin * 2;
}

// Draw loaded program
// (backdrop)
var _back_w = _ww - (16*16*2) - 64, _back_x = (_ww - _back_w) * 0.5;
draw_sprite_stretched_ext(sprWhite, 0, _back_x, 0, _back_w, _wh, c_black, 0.25);

// (text)
var _tx = _back_x + 32, _tx2 = _tx + _back_w - 64, _ty = 64,
	_xx = _tx, _yy = _ty, _scale = 3,
	_t = current_time * 0.001 * pi, _t_step = 2 * pi / 8;
draw_set_halign(0); draw_set_valign(0);
for (var i=0; i<array_length(glitch.program); i++)
{
	var _token = glitch.program[i], _tokenstr = "<NOP>",
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
	
	var _wid = string_width(_tokenstr)*_scale;
	if (_type == eTOKEN.LB || _xx + _wid > _tx2) // linebreak
	{
		_xx = _tx;
		_yy += (string_width("M")+1)*_scale;
		if (_type == eTOKEN.LB)
			continue;
	}
	
	// Draw
	var _x = _xx, _y = _yy + cos(_t) * 1 - 1,
		_a = sin(_t) * 4,
		_col = make_color_hsv(frac(_t * 0.01) * 255, 60, 255);
	draw_text_transformed_color(_x+_scale, _y+_scale, _tokenstr, _scale, _scale, _a, 0, 0, 0, 0, 1);
	draw_text_transformed_color(_x, _y, _tokenstr, _scale, _scale, _a, _col, _col, _col, _col, 1);
	
	_xx += _wid + 8 * _scale;
	_t += _t_step;
}

// Draw stack
var _stack_info = "TOSP: " + string(glitch.tosp) + " | T: " + string(glitch.t) + "\n";
draw_set_halign(2); draw_set_valign(0);
draw_text_transformed_color(_ww - 8 + 2, 8 + 2, _stack_info, 2, 2, 0, 0, 0, 0, 0, 1);
draw_text_transformed_color(_ww - 8, 8, _stack_info, 2, 2, 0, c_white, c_white, c_white, c_white, 1);

var _x = 8, _y = 8,
	_cell_w = 16,
	_cell_sz = 16;
draw_set_halign(1); draw_set_valign(1);
var _dx = _x, _dy = _y;
for (var i=0; i<=0xFF; i++)
{
	var _v = buffer_peek(glitch.stack, i << 2, buffer_u32),
		_h = ((_v >> 20) & 0xFFF) / 4095,
		_s = ((_v >> 8) & 0xFFF) / 4095,
		_v = (_v & 0xFF) / 255,
		_c = make_color_hsv(frac(_h + _v)*255, _s*255, _v*255);
	_dx = x + (i % _cell_w) * _cell_sz;
	_dy = y + (i div _cell_w) * _cell_sz;
	
	//draw_rectangle_color(_dx, _y, _dx+_cell_sz, _y+_cell_sz, _c, _c, _c, _c, false);
	draw_sprite_stretched_ext(sprWhite, 0, _dx, _dy, _cell_sz, _cell_sz, _c, 1);
	//draw_text_transformed_color(_dx+(_cell_sz>>1), _dy+(_cell_sz>>1), __tohex(_v), 1, 1, 0, c_blue, c_blue, c_blue, c_blue, 1);
}

// Draw FPS indicator
var _scale = 3, _x_mid = _x + _cell_sz * 8,
	_osc = osc_cos(1.2), _osc2 = abs(osc_sin(1.2));
_osc = power(abs(_osc), 2) * sign(_osc);
_osc2 = 1.0 - power(1.0 - _osc2, 2);
draw_sprite_ext(sprNoggmann, (_osc < 0) ? 0 : 1, _x_mid + _scale + _osc * 10, _y + _scale + _cell_sz * 20 + _osc2 * -6, _scale, _scale, 0, c_black, 1);
draw_sprite_ext(sprNoggmann, (_osc < 0) ? 0 : 1, _x_mid + _osc * 10, _y + _cell_sz * 20 + _osc2 * -6, _scale, _scale, 0, c_white, 1);

var _fps = "FPS: " + string(fps) + " / " + string(fps_real);
draw_set_halign(0); draw_set_valign(0);
draw_text_transformed_color(_x + 2, _y + 2 + _cell_sz * 17, _fps, 2, 2, 0, 0, 0, 0, 0, 1);
draw_text_transformed_color(_x, _y + _cell_sz * 17, _fps, 2, 2, 0, c_white, c_white, c_white, c_white, 1);

