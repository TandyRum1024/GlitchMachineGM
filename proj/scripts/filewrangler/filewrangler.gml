/*
	File wrangling
*/

/// @func fw_read_all_str(file_path)
function fw_read_all_str (_file)
{
	var _str = "",
		_FILE = file_text_open_read(_file);
	if (file_exists(_file) && _FILE)
	{
		while (!file_text_eof(_FILE))
		{
			_str += file_text_readln(_FILE);
		}
		file_text_close(_FILE);
		return _str;
	}
	else
	{
		// bunger_log("fw_read_all_str> READ FAILED: FILE `", _file, "` OPEN ERROR");
		return undefined;
	}
}

/// @func fw_save_string(file_path, string)
function fw_save_string (_file, _string)
{
	var _FILE = file_text_open_write(_file);
	if (_FILE)
	{
		file_text_write_string(_FILE, _string);
		file_text_close(_FILE);
		return true;
	}
	else
	{
		// bunger_log("fw_save_string> SAVE FAILED: FILE `", _file, "` OPEN ERROR");
		return false;
	}
}

/// @func fw_read_json(file_path)
function fw_read_json (_file)
{
	var _json_str = fw_read_all_str(_file);
	if (is_string(_json_str))
	{
		// return parsed struct
		return json_parse(_json_str);
	}
	else
	{
		// return undefined on file open error
		// bunger_log("fw_read_json> READ FAILED: FILE `", _file, "` OPEN ERROR");
		return undefined;
	}
}