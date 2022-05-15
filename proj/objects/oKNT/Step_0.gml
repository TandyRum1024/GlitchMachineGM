/// @description Auto reload
if (current_time - loadTime > 1000 && currentFile != "")
{
	glitch.load(currentFile, false);
	
	if (dspRate != glitch.rate)
	{
		dspRate = glitch.rate;
		audio_free_play_queue(dspSound);
		dspSound = audio_create_play_queue(buffer_u8, dspRate, audio_mono);
		
		fillAndQueueAll();
	}
	
	loadTime = current_time;
}

dspMuted ^= keyboard_check_pressed(ord("M"));
dspVolume = dspMuted ? 0 : 0.5;

// Select preset tunes
var _newtune = "";
for (var i=1; i<=9; i++)
{
	if (keyboard_check_pressed(ord(string(i))) && file_exists("tune" + string(i) + ".txt"))
		_newtune = "tune" + string(i) + ".txt";
}

if (_newtune != "")
{
	glitch.load(_newtune, true);
	currentFile = _newtune;
}


audio_sound_gain(dspSound, dspVolume, 0);

// View
var _ww = window_get_width(), _wh = window_get_height();
if (_ww != 0 && _wh != 0 && (_ww != surface_get_width(application_surface) || _wh != surface_get_height(application_surface)))
{
	surface_resize(application_surface, _ww, _wh);
	display_set_gui_size(_ww, _wh);
}
