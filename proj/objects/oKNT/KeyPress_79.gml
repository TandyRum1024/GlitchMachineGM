/// @description Open
var _file = get_open_filename("Text|*.txt", "");
if (_file != "")
{
	glitch = glitch_load_file(_file);
	currentFile = _file;
	fillAndQueueAll();
}
