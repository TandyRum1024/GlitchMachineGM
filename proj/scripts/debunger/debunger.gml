/*
	BUNGER?
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
	BUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGERBUNGER
*/
#macro _BUNGERMSG global.bungerScreenMsg

// Call initialization script
bunger_init();

function bunger_init ()
{
	// List containing on-screen debug message struct
	// Message struct: {msg: "", type: "normal", stack: 0, time: room_speed}
	global.bungerScreenMsg = ds_list_create();
	global.bungerScreenMsgDefaultTime = game_get_speed(gamespeed_fps) * 3;
	global.bungerScreenMsgFadeTime = game_get_speed(gamespeed_fps);
	
	// Table that contains colours to apply for each message type
	global.bungerColours = {
			ok: c_lime,
			error: c_red,
			flash: c_red, // to be animated @ bunger_update()
			pelvis: $00DDFF,
			def: c_lime
		};
}

/// @func bunger_log(v1[, v2, v3...])
function bunger_log ()
{
	var _msg = "";
	for (var i=0; i<argument_count; i++)
	{
		_msg += string(argument[i]);
	}
	show_debug_message(_msg);
}

/// @func bunger_show(message[, time, _type])
function bunger_show (_msg, _time, _type)
{
	// Check if the message is already in the list
	var _msg_data = undefined, _msg_idx = -1;
	for (var i=0; i<ds_list_size(_BUNGERMSG); i++)
	{
		var _data = _BUNGERMSG[| i];
		if (_data.msg == _msg)
		{
			_msg_data = _data;
			_msg_idx = i;
			break;
		}
	}
	
	bunger_log(_msg);
	if (!_msg_data)
	{
		// Add new message
		_msg_data = {
				msg: _msg,
				time: (_time!=undefined) ? _time : global.bungerScreenMsgDefaultTime,
				type: (_type!=undefined) ? _type : "def",
				stack: 0
			};
		ds_list_add(_BUNGERMSG, _msg_data);
	}
	else
	{
		// Increment message stack & update time and type and move it to the top of the line
		_msg_data.stack++;
		_msg_data.time = (_time!=undefined) ? _time : global.bungerScreenMsgDefaultTime;
		_msg_data.type = (_type!=undefined) ? _type : "def";
		ds_list_delete(_BUNGERMSG, _msg_idx);
		ds_list_add(_BUNGERMSG, _msg_data);
	}
}

function bunger_update ()
{
	// Update onscreen debug message
	for (var i=0; i<ds_list_size(_BUNGERMSG); i++)
	{
		var _data = _BUNGERMSG[| i];
		if (_data.time > 0)
		{
			_data.time--;
		}
		else if (_data.time != -1)
		{
			ds_list_delete(_BUNGERMSG, i);
			delete _data;
			i--;
		}
	}
	
	// Update colours
	global.bungerColours.flash = merge_colour(c_red, c_yellow, (current_time >> 2 & 1));
}

/// @func bunger_draw(x, y, _halign, _valign)
function bunger_draw (_x, _y, _halign, _valign)
{
	var _em = string_height("M");
	var _msgnum = ds_list_size(_BUNGERMSG);
	
	// Process align
	draw_set_halign(_halign); draw_set_valign(_valign);
	// (caulculate starting Y with vertical align applied)
	_y -= _valign * 0.5 * _em * _msgnum; // fa_top: 0, fa_middle: 1, fa_bottom: 2
	// (caulculate Y step with vertical align applied)
	var _stepy = _valign == fa_bottom ? -_em : _em;
	
	// Draw debug messages
	for (var i=_msgnum-1; i>=0; i--)
	{
		var _msg = _BUNGERMSG[| i], _type = _msg.type,
			_str = _msg.msg + (_msg.stack > 1 ? " ["+string(_msg.stack)+"x]" : ""),
			_col = global.bungerColours[$ _type] ? global.bungerColours[$ _type] : global.bungerColours.def,
			_alpha = clamp(_msg.time / global.bungerScreenMsgFadeTime, 0.0, 1.0);
		
		draw_text_colour(_x+1, _y+1, _str, c_black, c_black, c_black, c_black, _alpha);
		draw_text_colour(_x, _y, _str, _col, _col, _col, _col, _alpha);
		_y += _stepy;
	}
}

function bunger_clear ()
{
	ds_list_clear(_BUNGERMSG);
}

function bunger_destroy ()
{
	ds_list_destroy(_BUNGERMSG);
	bunger_log("bunger is dead");
}