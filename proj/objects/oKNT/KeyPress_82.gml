/// @description Reload
if (currentFile == "")
{
	currentFile = get_open_filename("Text|*.txt", "");
}

if (currentFile != "")
{
	glitch = glitch_load_file(currentFile);
	
	audio_free_play_queue(dspSound);
	dspSound = audio_create_play_queue(buffer_u8, dspRate, audio_mono);
	
	fillAndQueueAll();
	
	//bunger_log("AUDIO REVIVED");
	audio_play_sound(dspSound, 0, false);
	audio_sound_gain(dspSound, dspVolume, 0);
}
