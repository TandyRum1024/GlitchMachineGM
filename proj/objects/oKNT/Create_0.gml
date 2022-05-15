/// @description pain
currentFile = "tune-test.txt";
glitch = glitch_load_file(currentFile);
loadTime = current_time;

// Set up the audio buffer
dspRate = 8000;
dspBuffSize = 256;
dspBuffNum = 10;
dspBuffList = [];

dspBuffPlaying = undefined; // currently playing buffer
dspBuffReady = 0;

dspSound = audio_create_play_queue(buffer_u8, dspRate, audio_mono);
dspVolume = 0.5;

dspMuted = false;

repeat (dspBuffNum)
{
	array_push(dspBuffList, buffer_create(dspBuffSize, buffer_fast, 1));
}

// Method to fill those DSP buffer arrays
fillAndQueueAll = function () {
	// place new data in the used buffer
	for (var i=0; i<dspBuffNum; i++)
	{
		buffer_seek(dspBuffList[i], buffer_seek_start, 0);
		glitch.plz(dspBuffList[i], dspBuffSize);
		audio_queue_sound(dspSound, dspBuffList[i], 0, dspBuffSize);
		
		//show_debug_message("BUFFER " + string(dspBuffList[i]) + " QUEUE");
	}
	dspBuffPlaying = dspBuffList[0];
	dspBuffReady = dspBuffNum;
};
onBufferDone = function (_buff, _audio) {
	if (audio_is_playing(dspSound))
	{
		// place new data in the used buffer
		buffer_seek(_buff, buffer_seek_start, 0);
		glitch.plz(_buff, dspBuffSize);
		audio_queue_sound(dspSound, _buff, 0, dspBuffSize);
		dspBuffPlaying = _buff;
	}
	else
	{
		// start new
		audio_free_play_queue(dspSound);
		dspSound = audio_create_play_queue(buffer_u8, dspRate, audio_mono);
		
		buffer_seek(_buff, buffer_seek_start, 0);
		glitch.plz(_buff, dspBuffSize);
		audio_queue_sound(dspSound, _buff, 0, dspBuffSize);
		dspBuffPlaying = _buff;
		
		//bunger_log("AUDIO REVIVED");
		audio_play_sound(dspSound, 0, false);
		audio_sound_gain(dspSound, dspVolume, 0);
	}
};

fillAndQueueAll();
audio_play_sound(dspSound, 0, false);
audio_sound_gain(dspSound, dspVolume, 0);

// Sick visuals
visualSurf = surface_create(256, dspBuffSize);
visualSurfPrev = surface_create(256, dspBuffSize);
buffSurf = buffer_create(256*dspBuffSize*4, buffer_fast, 1);

