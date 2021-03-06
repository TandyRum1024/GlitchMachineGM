/*
	Illegal bytebeat stuff
	MMXXI ZIK
*/
#macro BYTEBEAT_MAXINT 0xFFFFFFFF
#macro BYTEBEAT_TOSP_MAX 0x3FF

enum eTOKEN
{
	LB = 0,
	NOP,
	NUM,
	VAR,
	T,
	PUT,
	DROP,
	MUL,
	DIV,
	ADD,
	SUB,
	MOD,
	LSHIFT,
	RSHIFT,
	AND,
	OR,
	XOR,
	NOT,
	DUP,
	PICK,
	SWAP,
	LT,
	GT,
	EQ
};

// token index to token type string conversion table
global.glitchTokensName = [
	"LB", // LINEBREAK
	"NOP", // NOP
	"NUM", // NUM
	"VAR", // VAR
	"T",	// T
	"PUT",	// PUT
	"DROP", // DROP
	
	"*", // MUL
	"/", // DIV
	"+", // ADD
	"-", // SUB
	"%", // MOD
	
	"<<", // LSHIFT
	">>", // RSHIFT
	"&", // AND
	"|", // OR
	"^", // XOR
	"~", // NOT
	
	"DUP", // DUP
	"PICK", // PICK 
	"SWAP", // SWAP
	"<", // LT
	">", // GT
	"=", // EQ
];

function Glitch () constructor
{
	program = []; // array of opcodes & operands
	programSize = 0;
	stack = buffer_create(256*4, buffer_fixed, 4); // program stack
	tosp = 0; // top of stack pointer (TOSP)
	t = 0; // time/current sample index
	register = {}; // registers that holds variables
	
	rate = 8000;
	
	// Clear stack w/ 0
	buffer_fill(stack, 0, buffer_u32, 0, 256);
	buffer_seek(stack, buffer_seek_start, 0);
	
	clear = function (_rate=8000) {
		// Clear stack w/ 0
		buffer_fill(stack, 0, buffer_u32, 0, 256);
		buffer_seek(stack, buffer_seek_start, 0);
		tosp = 0;
		
		rate = _rate;
		
		program = [];
		register = {};
	};
	
	/// @func plz(buff, num_samples)
	/// @desc Evaluate program, fill the buffer with given amount of sound samples
	plz = function (_buff, _num_samples) {
		var i, _t = t, _stack = stack, _tosp = tosp;
		var _token, _v1, _v2, _v3, _result;
		
		// Repeat as much as needed
		repeat (_num_samples)
		{
			//bunger_log("T: ", _t);
			
			#region Execute program, fill 1 sample to buffer
			i = 0;
			repeat (programSize)
			{
				// Fetch 1 token from the program & execute
				_token = program[i];
				//bunger_log(" > TOKEN: ", global.glitchTokensName[_token[0]]);
				
				switch (_token[0])
				{
					case eTOKEN.NUM:
						// push value to stack
						// (push _token[1])
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _token[1]);
						break;
					case eTOKEN.VAR:
						_v1 = register[$ _token[1]] ?? 0;
						// (push _v1)
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _v1);
						break;
					case eTOKEN.T:
						// (push _t)
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _t);
						break;
				
					case eTOKEN.PUT: // put value1 to _stack[TOSP-value2]
						// get v3: top value from _stack % 256 + 1
						_v3 = buffer_peek(_stack, _tosp, buffer_u32) & 0xFF + 1;
						
						// set _stack[TOSP-v3] to second-top value from _stack
						//poke((tosp - (_v3 << 2)) & BYTEBEAT_TOSP_MAX, peep(tosp - 4));
						buffer_poke(_stack, (_tosp - (_v3 << 2)) & BYTEBEAT_TOSP_MAX, buffer_u32, buffer_peek(_stack, (_tosp - 4) & BYTEBEAT_TOSP_MAX, buffer_u32));
						break;
				
					case eTOKEN.DROP: // pop one value
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						break;
				
					case eTOKEN.MUL:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 * _v1));
						break;
				
					case eTOKEN.DIV:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v1 == 0) ? 0 : (_v2 / _v1));
						break;
					
					case eTOKEN.ADD:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 + _v1));
						break;
				
					case eTOKEN.SUB:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 - _v1));
						break;
				
					case eTOKEN.MOD:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v1 == 0) ? 0 : (_v2 % _v1));
						break;
				
					case eTOKEN.LSHIFT:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 << _v1));
						break;
				
					case eTOKEN.RSHIFT:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 >> _v1));
						break;
				
					case eTOKEN.AND:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 & _v1));
						break;
				
					case eTOKEN.OR:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 | _v1));
						break;
				
					case eTOKEN.XOR:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, (_v2 ^ _v1));
						break;
					
					case eTOKEN.NOT:
						// pop 1 value
						buffer_poke(_stack, _tosp, buffer_u32, ~buffer_peek(_stack, _tosp, buffer_u32));
						break;
				
					case eTOKEN.DUP:
						// peek 1 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _v1);
						break;
				
					case eTOKEN.PICK:
						// get v1: _stack[TOSP] + 1 & 0xFF
						// get v4: _stack[TOSP - v1]
						// replace v4 to stack
						_v1 = (buffer_peek(_stack, _tosp, buffer_u32) + 1) & 0xFF;
						_v2 = buffer_peek(_stack, (_tosp - (_v1 << 2)) & BYTEBEAT_TOSP_MAX, buffer_u32);
						buffer_poke(_stack, _tosp, buffer_u32, _v2);
						break;
				
					case eTOKEN.SWAP:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_v2 = buffer_peek(_stack, (_tosp - 4) & BYTEBEAT_TOSP_MAX, buffer_u32);

						buffer_poke(_stack, _tosp, buffer_u32, _v2);
						buffer_poke(_stack, (_tosp - 4) & BYTEBEAT_TOSP_MAX, buffer_u32, _v1);
						break;
				
					case eTOKEN.LT:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _v2 < _v1 ? 0xFFFFFFFF : 0x0);
						break;
				
					case eTOKEN.GT:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _v2 > _v1 ? 0xFFFFFFFF : 0x0);
						break;
				
					case eTOKEN.EQ:
						// pop 2 value
						_v1 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						_v2 = buffer_peek(_stack, _tosp, buffer_u32);
						_tosp = (_tosp - 4) & BYTEBEAT_TOSP_MAX;
						
						_tosp = (_tosp + 4) & BYTEBEAT_TOSP_MAX;
						buffer_poke(_stack, _tosp, buffer_u32, _v2 == _v1 ? 0xFFFFFFFF : 0x0);
						break;
				}
				
				i++;
			}
			
			// Increment temporary T, fill the audio buffer with last value from the stack
			//t++;
			_t++;
			
			buffer_write(_buff, buffer_u8, buffer_peek(_stack, _tosp, buffer_u32) & 0xFF);
			#endregion
		}
		
		// Update machine variables
		t = _t;
		tosp = _tosp;
	};
	
	push = function (_val) {
		//tosp = (tosp+1) & 0xFF; buffer_seek(stack, buffer_seek_start, tosp<<2); // increment & emulate uint8 behaviour on TOSP
		//buffer_write(stack, buffer_u32, _val & 0xFFFFFFFF);
		tosp = (tosp + 4) & BYTEBEAT_TOSP_MAX;
		buffer_poke(stack, tosp, buffer_u32, _val);
		//bunger_log(" > PUSH(", tosp, "): ", buffer_peek(stack, tosp<<2, buffer_u32));
	};
	
	pop = function () {
		//var _v = buffer_peek(stack, tosp<<2, buffer_u32);
		//tosp = (tosp-1) & 0xFF; // decrement & emulate uint8 behaviour on TOSP
		//bunger_log(" > POP(", tosp, "): ", buffer_peek(stack, tosp<<2, buffer_u32));
		var _v = buffer_peek(stack, tosp, buffer_u32);
		tosp = (tosp - 4) & BYTEBEAT_TOSP_MAX;
		return _v;
	};
	
	peep = function (_tosp) {
		return buffer_peek(stack, _tosp, buffer_u32);
	};
	
	poke = function (_tosp, _val) {
		return buffer_poke(stack, _tosp, buffer_u32, _val);
	};
	
	/// @func load(_file, _reset_t = false)
	load = function (_file, _reset_t = false) {
		var _res = glitch_load_file(_file, self);
		if (_reset_t && _res)
			t = 0;
	};
}

/// @func glitch_load_file(file)
/// @desc Load from file
function glitch_load_file (_file, _glitch=new Glitch())
{
	var _FILE = file_text_open_read(_file);
	if (_FILE == -1)
	{
		bunger_log("glitchmachine::load> FILE READING ERROR`", _file, "`!");
		return undefined;
	}
	
	bunger_log("glitchmachine::load> LOADING `", _file, "`...");
	
	// Parse the file and create a new glitch instance
	var _ignoremode = false, _ignore_lb = true;
	//var _glitch = new Glitch();
	_glitch.clear(8000);
	while (!file_text_eof(_FILE))
	{
		// Read line & take care of newline n' stuff
		var _line = file_text_readln(_FILE);
		//bunger_log("LINE: `", _line, "` | IGNORE: ", _ignoremode);
		
		// (strip prefix whitespace)
		var _c = string_char_at(_line, 1);
		while (_c == " " || _c == "\t")
		{
			_line = string_delete(_line, 1, 1);
			_c = string_char_at(_line, 1);
		}
		
		// Detect parenthesis (comment)
		if (string_char_at(_line, 1) == "(")
		{
			if (string_pos(")", _line) == 0) // check for single-line comment
				_ignoremode = true;
			continue;
		}
		else if (string_char_at(_line, 1) == ")")
		{
			_ignoremode = false;
			continue;
		}
		
		// If current line is control line or inside the comment, then skip this line
		if (_ignoremode || string_char_at(_line, 1) == "$")
		{
			// check for control line
			if (string_copy(_line, 1, 2) == "$r") // rate
			{
				var _newrate = real(string_delete(_line, 1, 2));
				_glitch.rate = _newrate;
			}
			continue;
		}
		
		// Parse line
		var _tokenpos = 1, _nextpos = string_pos_ext(" ", _line, _tokenpos);
		while (_tokenpos)
		{
			var _tokenstr;
			if (_nextpos > 0)
				_tokenstr = string_copy(_line, _tokenpos, _nextpos - _tokenpos);
			else // last token on the line
				_tokenstr = string_copy(_line, _tokenpos, string_length(_line) - _tokenpos + 1);
			
			// Handle newline
			_tokenstr = string_replace_all(_tokenstr, "\r\n", "");
			_tokenstr = string_replace_all(_tokenstr, "\n", "");
			if (_tokenstr != "")
			{
				// bunger_log("TOKEN (", _tokenpos, " ~ ", _nextpos, "): `", _tokenstr, "`");
				
				// Detect parenthesis (comment)
				if (string_char_at(_tokenstr, 1) == "(")
					_ignoremode = true;
				else if (string_char_at(_tokenstr, 1) == ")")
					_ignoremode = false;
				else if (!_ignoremode)
				{
					// Generate token from token string
					var _token = glitch_create_token_from(_tokenstr);
					if (_token[0] != eTOKEN.LB)
						_ignore_lb = false;
					// Add to program
					if (!_ignore_lb)
						array_push(_glitch.program, _token);
				}
			}
			
			// Find next token position
			if (_nextpos == 0) // last token; set next token position to 0 to end parsing
				_tokenpos = 0;
			else
			{
				_tokenpos = _nextpos;
				while (_tokenpos <= string_length(_line))
				{
					if (string_char_at(_line, _tokenpos) != " " &&
						string_char_at(_line, _tokenpos) != "\n")
						break;
					_tokenpos++;
				}
				_nextpos = string_pos_ext(" ", _line, _tokenpos);
			}
		}
		
		// Add linebreak
		if (!_ignore_lb)
			array_push(_glitch.program, glitch_create_token_from("\n"));
	}
	file_text_close(_FILE);
	
	bunger_log("glitchmachine::load> DONE!");
	_glitch.programSize = array_length(_glitch.program);
	return _glitch;
}

/// @func glitch_load_str(code)
/// @desc Load from code in string type
function glitch_load_str (_str)
{
	if (_str == "")
		return undefined;
	
	// Parse the file and create a new glitch instance
	var _glitch = new Glitch();
	// Read line & take care of newline n' stuff
	var _line = _str;
	if (string_char_at(_line, string_length(_line)) == "\n")
		_line = string_delete(_line, string_length(_line), 1);
		
	// Parse string
	var _ignoremode = false;
	var _tokenpos = 1, _nextpos = string_pos_ext(" ", _line, _tokenpos);
	while (_tokenpos)
	{
		var _tokenstr;
		if (_nextpos + 1)
			_tokenstr = string_copy(_line, _tokenpos, _nextpos - _tokenpos);
		else // last token on the string
			_tokenstr = string_copy(_line, _tokenpos, string_length(_line) - _tokenpos + 1);
		
		// handle newline
		// _tokenstr = string_replace_all(_tokenstr, "\n", "");
		if (_tokenstr != "")
		{
			// Detect parenthesis (comment)
			if (_tokenstr == "(")
				_ignoremode = true;
			else if (_tokenstr == ")")
				_ignoremode = false;
			else if (!_ignoremode)
			{
				// Generate token from token string
				var _token = glitch_create_token_from(_tokenstr);
				// Add to program
				array_push(_glitch.program, _token);
			}
		}
			
		// Find next token position
		if (_nextpos == 0) // last token; set next token position to 0 to end parsing
			_tokenpos = 0;
		else
		{
			_tokenpos = _nextpos;
			while (_tokenpos <= string_length(_line))
			{
				if (string_char_at(_line, _tokenpos) != " " &&
					string_char_at(_line, _tokenpos) != "\n")
					break;
				_tokenpos++;
			}
			_nextpos = string_pos_ext(" ", _line, _tokenpos);
		}
	}
	
	_glitch.programSize = array_length(_glitch.program);
	return _glitch;
}

/// @func glitch_get_token_type(token_str)
/// @desc Matches and returns token type(index) from given string. Returns eTOKEN.NOP if there is no matching token
function glitch_get_token_type (_str)
{
	// Check if given string is variable or numeric constant
	if (string_copy(_str, 1, 2) == "0x" ||
		string_digits(_str) != "") // hex or dec integer
		return eTOKEN.NUM;
	else if (_str == "t") // time variable
		return eTOKEN.T;
	else if (_str == "\n") // linebreak
		return eTOKEN.LB;
	else if (_str == "") // nothing. bloody hell
		return eTOKEN.NOP;
	
	switch (string_lower(_str))
	{
		case "*":
		case "mul":
			return eTOKEN.MUL;
			break;
		case "/":
		case "div":
			return eTOKEN.DIV;
			break;
		case "+":
		case "add":
			return eTOKEN.ADD;
			break;
		case "-":
		case "sub":
			return eTOKEN.SUB;
			break;
		case "%":
		case "mod":
			return eTOKEN.MOD;
			break;
			
		case "<<":
		case "lshift":
			return eTOKEN.LSHIFT;
			break;
		case ">>":
		case "rshift":
			return eTOKEN.RSHIFT;
			break;
		case "&":
		case "and":
			return eTOKEN.AND;
			break;
		case "|":
		case "or":
			return eTOKEN.OR;
			break;
		case "^":
		case "xor":
			return eTOKEN.XOR;
			break;
		case "!":
		case "~":
		case "not":
			return eTOKEN.NOT;
			break;
		case "put":
			return eTOKEN.PUT;
			break;
		case "drp":
		case "drop":
			return eTOKEN.DROP;
			break;
		case "dup":
			return eTOKEN.DUP;
			break;
		case "pck":
		case "pick":
			return eTOKEN.PICK;
			break;
		case "swp":
		case "swap":
			return eTOKEN.SWAP;
			break;
		case "<":
		case "lt":
			return eTOKEN.LT;
			break;
		case ">":
		case "gt":
			return eTOKEN.GT;
			break;
		case "=":
		case "eq":
			return eTOKEN.EQ;
			break;
	}
	
	//bunger_log("glitch::parse> VARIABLE FOUND: `", _str, "`");
	return eTOKEN.VAR;
}

/// @func glitch_create_token_from(token_str)
/// @desc Matches and returns a new token from given string.
function glitch_create_token_from (_str)
{
	var _type = glitch_get_token_type(_str), _val = 0, _hex = false;
	if (_type == eTOKEN.NUM)
	{
		if (string_copy(_str, 1, 2) == "0x")
		{
			_hex = true;
			_val = __parsehex(string_delete(_str, 1, 2));
			//show_debug_message("HEX: `" + _str + "` -> " + string(_val) + " (0x" + __tohex(_val) + ")");
		}
		else
		{
			_val = real(_str);
		}
	}
	else if (_type == eTOKEN.VAR)
		_val = _str;
	return [_type, _val, _hex];
}

function __parsehex (_str)
{
	static TBL = "0123456789ABCDEF";
	var _val = 0, _p;
	for (var i=1; i<=string_length(_str); i++)
	{
		_p = string_pos(string_char_at(_str, i), TBL) - 1;
		_val = (_val << 4) + max(_p, 0);
	}
	return _val;
}

function __tohex (_num)
{
	static TBL = "0123456789ABCDEF";
	var _str = "";
	while (_num)
	{
		_str = string_char_at(TBL, (_num & 0xF) + 1) + _str;
		_num = _num >> 4;
	}
	return _str == "" ? "0" : _str;
}
