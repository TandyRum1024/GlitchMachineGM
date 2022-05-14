/// @description Auto reload
/*
if (current_time - loadTime > 1000)
{
	glitch = glitch_load_file("tune-test.txt");
	loadTime = current_time;
}
*/
dspMuted ^= keyboard_check_pressed(ord("M"));
dspVolume = dspMuted ? 0 : 0.5;

audio_sound_gain(dspSound, dspVolume, 0);
