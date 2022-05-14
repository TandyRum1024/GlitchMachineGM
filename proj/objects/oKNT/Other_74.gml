/// @description Listen for audio queue event
var _id = async_load[? "queue_id"],
	_buffer_id = async_load[? "buffer_id"];

if (async_load[? "queue_shutdown"] == false) // Normal playback
{
	// Fill the buffer, and queue it ASAP
	onBufferDone(_buffer_id, _id);
	
	show_debug_message("BUFFER " + string(_buffer_id) + " REFILL");
}

/*
if (!audio_is_playing(_id))
{
	bunger_log("AUDIO REVIVED");
	audio_play_sound(_id, 0, false);
}*/
// bunger_log("AUDIO QUEUE FIRED");
