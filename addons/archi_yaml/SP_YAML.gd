class_name SPYaml 

enum OPTION_TYPE{ BOOLEAN, LIST, INT } 

# - static functions
# - read archi yaml options file 
# - parse archi yaml options 
# - return a dictionary of options with descriptions
static var current_header_section : String = "" 
static var option_sections : Array[String]

static func read(path : String) -> Dictionary: 
	var data: Dictionary = {} 
	var current_section : String = "file_options" 
	current_header_section = ""
	option_sections.clear()
	
	var game_options_started : bool = false 
	var game_name : String = "" 
	
	#check if file is valid 
	if !FileAccess.file_exists(path): 
		printerr("no file at path: %s" %path) 
		return data 
	
	if !path.ends_with(".yaml"): 
		printerr("no valid yaml file at path: %s" %path) 
		return data 
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ) 
	
	if FileAccess.get_open_error(): 
		printerr("file couldn't open at path: %s" %path) 
		printerr("\tError: %s" %FileAccess.get_open_error()) 
		return data 
	
	data[current_section]={} 
	
	#go through all lines of the yaml 
	while !file.eof_reached(): 
		var original_line : String = file.get_line() 
		var current_indent = get_indent_info(original_line) 
		var line : String = original_line.strip_edges() 
		
		if line == "" or line.begins_with('#'): 
			#if game options have started use this to scan for sections and descriptions, but let's first focus on reading all the data 
			continue 
		
		# split parts 
		var parts: PackedStringArray = split_yaml_line(line)
		var key: String = parts[0].strip_edges()
		
		#if key is game, save game name
		if key == "game": 
			game_name = parse_value(parts[1]) 
		
		if key == game_name: 
			current_section = "randomizer_options"
			key = "options"
			data[current_section] = {} 
		
		#parse value 
		if parts.size() == 2: 
			data[current_section][key] = parse_value(parts[1]) 
		else: 
			data[current_section][key] = parse_option(file,current_indent)
			
		#if key is description, ad sp message 
		if key == "description": 
			data[current_section][key] = parts[1] + " | (options created by SP YAML)" 
	
	data["option_sections"] = option_sections
	
	return data 
	
static func parse_value(value : String) -> Variant: 
	var stripped_value = value.split("#")[0].strip_edges() 
	
	if stripped_value.is_valid_int(): 
		return int(stripped_value) 
	if stripped_value.to_lower() == "true": 
		return true 
	if stripped_value.to_lower() == "false": 
		return false 
	if stripped_value.begins_with('[') and stripped_value.ends_with(']'):
		var return_arr : Array[Variant]
		var stripped_input = stripped_value.substr(1,stripped_value.length()-2)
		var items : PackedStringArray = split_top_level(stripped_input)
		for i in items:
			return_arr.push_back(parse_value(i))
		return return_arr
	if stripped_value.begins_with('{') and stripped_value.ends_with('}'):
		var return_dict : Dictionary = {}
		var stripped_input = stripped_value.substr(1,stripped_value.length()-2)
		var items : PackedStringArray = split_top_level(stripped_input)
		for i in items:
			var sections = split_yaml_line(i)
			var key = sections[0]
			return_dict[key] = parse_value(sections[1].strip_edges())
		return return_dict
	return stripped_value 
	
static func parse_option(file: FileAccess, _current_indent : int) -> Dictionary: 
	var dict: Dictionary = {} 
	var prev_pos : int = 0 
	var description : String = "" 
	
	if current_header_section != "":
		dict["section"] = current_header_section
	while !file.eof_reached(): 
		prev_pos = file.get_position() 
		var original_line: String = file.get_line() 
		var current_indent : int = get_indent_info(original_line) 
		var line = original_line.strip_edges() 
		
		if line == "": 
			continue 
			
		if line.begins_with('#') and line.ends_with('#') and line != "#": 
			var trimmed = line.remove_chars('#').strip_edges() 
			if trimmed != "": 
				current_header_section = trimmed
				option_sections.push_back(trimmed)
			continue 
				
		if line.begins_with('#'): 
			description += line.substr(1,line.length()).strip_edges()+"\n"
			continue 
			
		if current_indent <= _current_indent: 
			file.seek(prev_pos) 
			break 
		
		if line != "": 
			if current_header_section != "":
				if !dict.has("value"):
					dict["value"] = {}
			
			if line.begins_with('[') and line.ends_with(']'):
				if(current_header_section != ""):
					dict["value"]["list"] = parse_value(line)
				else:
					dict["list"] = parse_value(line) 
					
			elif line.begins_with('{') and line.ends_with('}'):
				if(current_header_section != ""):
					dict["value"]["dict"] = parse_value(line)
				else:
					dict["dict"] = parse_value(line) 
			
			else:
				#var parts: PackedStringArray = line.split(':',false,1) 
				var parts: PackedStringArray = split_yaml_line(line)
				#print(parts)
				var key: String = parts[0].strip_edges() 
				
				var save_pos = file.get_position()
				var next_line = file.get_line().strip_edges()
				file.seek(save_pos)
				if next_line.begins_with('-') and !next_line.ends_with(':'):
					if(current_header_section != ""):
						dict["value"]["list"] = parse_list(file)
					else:
						dict["list"] = parse_list(file)

				elif parts.size() == 2: 
					if(current_header_section != ""):
						dict["value"][key] = parse_value(parts[1])
					else:
						dict[key] = parse_value(parts[1]) 
						
				else: 
					if(current_header_section != ""):
						dict["value"][key] = parse_option(file,current_indent)
					else:
						dict[key] = parse_option(file,current_indent)
				
	if description != "":
		dict["description"] = description 
	return dict 
	
static func parse_list(file: FileAccess) -> Array[String]:
	var list : Array[String] = []
	var prev_pos : int = 0 
	
	while !file.eof_reached(): 
		prev_pos = file.get_position() 
		var line : String = file.get_line().strip_edges() 
		
		if !line.begins_with('-'):
			file.seek(prev_pos)
			break
		
		var value = line.substr(1,line.length()).strip_edges()
		list.push_back(value)
	
	return list
	pass

static func get_indent_info(line: String) -> int: 
	var indent = 0 
	
	for c in line: 
		if c == " ": 
			indent += 1 
		elif c == "\t": 
			indent += 4 
		else: break 
		
	return indent

static func split_top_level(text: String, delimiter: String = ",") -> PackedStringArray:
	var result: PackedStringArray = []
	var current := ""

	var depth_curly := 0
	var depth_square := 0
	var in_quote:= false

	for c in text:
		match c:
			"{":
				depth_curly += 1
			"}":
				depth_curly -= 1
			"[":
				depth_square += 1
			"]":
				depth_square -= 1
			"'":
				in_quote = !in_quote

		if c == delimiter and depth_curly == 0 and depth_square == 0 and !in_quote:
			result.append(current)
			current = ""
		else:
			current += c

	if current != "":
		result.append(current)

	return result

static func split_top_level_once(text: String, delimiter: String = ":") -> PackedStringArray:
	var depth_curly := 0
	var depth_square := 0
	var in_quote:= false

	for i in range(text.length()):
		var c = text[i]

		match c:
			"{":
				depth_curly += 1
			"}":
				depth_curly -= 1
			"[":
				depth_square += 1
			"]":
				depth_square -= 1
			"'":
				in_quote = !in_quote

		if c == delimiter and depth_curly == 0 and depth_square == 0 and !in_quote:
			return [
				text.substr(0, i),
				text.substr(i + 1)
			]

	return [text]

static func split_yaml_line(line: String) -> PackedStringArray:
	var in_single := false
	var in_double := false

	for i in range(line.length()):
		var c = line[i]

		# Toggle single quotes
		if c == "'" and not in_double:
			# Ignore apostrophes inside words
			var prev_is_letter := false
			var next_is_letter := false

			if i > 0:
				prev_is_letter = is_letter(line[i - 1])

			if i < line.length() - 1:
				next_is_letter = is_letter(line[i + 1])

			var is_apostrophe = prev_is_letter and next_is_letter

			if not is_apostrophe:
				in_single = !in_single

		# Toggle double quotes
		elif c == '"' and not in_single:
			in_double = !in_double

		# Found separator outside quotes
		elif c == ":" and not in_single and not in_double:
			if line.substr(i + 1).strip_edges() != "":
				return [line.substr(0, i).strip_edges(), line.substr(i + 1).strip_edges()]
			else:
				return [line.substr(0, i).strip_edges()]
	return []

static func is_letter(c: String) -> bool:
	return c.unicode_at(0) >= 65 and c.unicode_at(0) <= 122
