/// @description Reload
if (currentFile == "")
{
	currentFile = get_open_filename("Text|*.txt", "");
}

if (currentFile != "")
{
	glitch = glitch_load_file(_file);
	fillAndQueueAll();
}
