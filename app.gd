extends Control

const static_template_dir : String = "C:/ProgramData/Archipelago/Players/Templates"
const static_players_dir : String = "C:/ProgramData/Archipelago/Players"

@export_group("dialogs")
@export var template_folder_popup: FileDialog
@export var manual_yaml_select_popup: FileDialog
@export var save_yaml_popup: FileDialog
@export var save_settings_popup: FileDialog
@export var load_settings_popup: FileDialog
@export var load_settings_select_yaml_popup: FileDialog

@export_group("ui elements")
#@export var template_select: OptionButton
@export var template_selector: YAMLSelector
@export var load_template_button: Button
@export var yaml_folder_warning: Label
@export var locate_template_folder_button: Button
@export var manual_locate_button: Button
@export var save_yaml_button: Button
@export var save_yaml_template_button: Button
@export var load_yaml_to_start_panel: VBoxContainer
@export var yaml_saved_to_text : RichTextLabel
@export var save_settings_button : Button
@export var load_settings_button : Button
@export var player_name_field : LineEdit

@export_group("yaml elements")
@export var game_name_label : RichTextLabel
@export var requirements_label : RichTextLabel
@export var requirements_tooltip : TextureRect
@export var description_box : TextEdit
@export var options_creator : YamlOptionsCreator

@export_group("misc")
@export var tooltip: PanelContainer

var template_folder_directory : String = ""
var save : SaveData
var last_save_location : String = ""
var last_save_file_name : String = ""
var last_manual_load_location : String = ""
var last_settings_load_location : String = ""
var last_settings_save_location : String = ""

var current_yaml_template_dict : Dictionary

func _save():
	if(true):
		SaveLoad.saveData(save)

func _ready() -> void:
	_connect_signals()
	_check_template_folder_popup()
	var ui_size = DisplayServer.screen_get_dpi() / 96.0
	get_tree().root.content_scale_factor = ui_size
	
	var output = []
	OS.execute(
	"cmd.exe",
	[
		"/c",
        'cd /d "C://ProgramData/Archipelago" && ArchipelagoLauncher.exe "Export World Data"'
	],
	output
	)
	#OS.execute("C:/ProgramData/Archipelago/ArchipelagoLauncher.exe",["Export World Data"],output)
	#print(output)
	
	

func _connect_signals():
	get_window().files_dropped.connect(_file_dropped)
	locate_template_folder_button.pressed.connect(_template_folder_popup)
	manual_yaml_select_popup.file_selected.connect(_manual_file_selected)
	manual_locate_button.pressed.connect(_manual_select_popup)
	template_folder_popup.dir_selected.connect(_template_folder_selected)
	load_template_button.pressed.connect(_load_template_yaml)
	save_yaml_button.pressed.connect(_save_yaml_popup)
	save_yaml_popup.file_selected.connect(_attempt_save_yaml)
	load_settings_button.pressed.connect(_load_settings_popup)
	load_settings_popup.file_selected.connect(_load_settings)
	save_settings_button.pressed.connect(_save_settings_popup)
	save_settings_popup.file_selected.connect(_save_settings)
	load_settings_select_yaml_popup.file_selected.connect(_manual_file_selected_option)

func _show_load_settings_select_yaml():
	load_settings_select_yaml_popup.title = "yaml file for settings not found in template folder. please select yaml file for: " + str(Settingload.settings["game"])
	load_settings_select_yaml_popup.popup()
	
	if template_folder_directory != "":
		load_settings_select_yaml_popup.current_dir = template_folder_directory
	else:
		load_settings_select_yaml_popup.current_dir = "C://"
	pass

func _save_settings_popup():
	save_settings_popup.title = "save spyaml file"
	save_settings_popup.popup()
	
	if last_settings_save_location != "":
		save_settings_popup.current_dir = last_settings_save_location
	else:
		save_settings_popup.current_dir = "C://"
	pass
	
func _save_settings(_path):
	last_settings_save_location = save_settings_popup.current_dir
	save.data["last_settings_save_location"] = var_to_str(last_settings_save_location)
	_save()
	
	var final_dictionary : Dictionary = {}
	final_dictionary["game"] = current_yaml_template_dict["file_options"]["game"]
	final_dictionary["settings"] = get_option_setting_dict()
	var file = FileAccess.open(_path, FileAccess.WRITE)
	file.store_line(var_to_str(final_dictionary))
	file.close()
	pass

func _load_settings_popup():
	load_settings_popup.title = "please select a spyaml file"
	load_settings_popup.popup()
	
	if last_settings_load_location != "":
		load_settings_popup.current_dir = last_settings_load_location
	else:
		load_settings_popup.current_dir = "C://"
	pass

func _load_settings(_path):
	if(_path.get_extension() == "spyaml"):
		last_settings_load_location = load_settings_popup.current_dir
		save.data["last_settings_load_location"] = var_to_str(last_settings_load_location)
		_save()
		_open_spyaml_file(_path)
	pass

func _manual_select_popup():
	manual_yaml_select_popup.title = "please select a yaml file"
	manual_yaml_select_popup.popup()
	
	if last_manual_load_location != "":
		manual_yaml_select_popup.current_dir = last_manual_load_location
	elif(DirAccess.dir_exists_absolute(static_template_dir)):
		manual_yaml_select_popup.current_dir = static_template_dir
	else:
		manual_yaml_select_popup.current_dir = "C://"
	pass

func _check_template_folder_popup():
	save = SaveLoad.getSaveData()
	if !SaveLoad.getSaveDataExists(0):
		if(DirAccess.dir_exists_absolute(static_template_dir)):
			_template_folder_selected(static_template_dir)
		else:
			_template_folder_popup()
		pass
	else:
		if save.data.has("template_folder_dir"):
			template_folder_directory = str_to_var(save.data["template_folder_dir"])
			_attempt_populate_template_select()
		if save.data.has("last_save_location"):
			last_save_location = str_to_var(save.data["last_save_location"])
		if save.data.has("last_manual_load_location"):
			last_manual_load_location = str_to_var(save.data["last_manual_load_location"])
		if save.data.has("last_settings_load_location"):
			last_settings_load_location = str_to_var(save.data["last_settings_load_location"])
		if save.data.has("last_settings_save_location"):
			last_settings_save_location = str_to_var(save.data["last_settings_save_location"])

func _template_folder_popup():
	template_folder_popup.title = "please select yaml template folder"
	template_folder_popup.popup()
	if template_folder_directory != "":
		template_folder_popup.current_dir = template_folder_directory
	else:
		if(DirAccess.dir_exists_absolute(static_template_dir)):
			template_folder_popup.current_dir = static_template_dir
		else:
			template_folder_popup.current_dir = "C://"

func _template_folder_selected(_path):
	template_folder_directory = _path
	save.data["template_folder_dir"] = var_to_str(_path)
	_save()
	_attempt_populate_template_select()
	pass

func set_template_buttons_enabled(enabled : bool):
	#template_select.disabled = !enabled
	load_template_button.disabled = !enabled
	if(enabled):
		yaml_folder_warning.visible = false
	else:
		yaml_folder_warning.visible = true

func _attempt_populate_template_select():
	var dir = DirAccess.open(template_folder_directory)

	if dir == null:
		return
	
	#template_select.clear()
	template_selector.remove_buttons()
	dir.list_dir_begin()
	for f : String in dir.get_files():
		if f.get_extension() == "yaml":
			template_selector.spawn_button(f.substr(0,f.length()-f.get_extension().length()-1))
			#template_select.add_item(f.substr(0,f.length()-f.get_extension().length()-1))
	
	if template_selector.buttons.size() > 0:
		template_selector.buttons[0].select_label()
		set_template_buttons_enabled(true)
	else:
		set_template_buttons_enabled(false)

func _manual_file_selected(_path : String):
	if(_path.get_extension() == "yaml"):
		last_manual_load_location = manual_yaml_select_popup.current_dir
		save.data["last_manual_load_location"] = var_to_str(last_manual_load_location)
		_save()
		_open_yaml_file(_path)
	pass

func _manual_file_selected_option(_path : String):
	if(_path.get_extension() == "yaml"):
		_open_yaml_file(_path,true)
	pass

func _file_dropped(_files):
	if(!template_folder_popup.visible && !manual_yaml_select_popup.visible && !save_yaml_popup.visible):
		var dropped_file : String = _files[0]
		if dropped_file.get_extension() == "yaml":
			_open_yaml_file(dropped_file)
		if dropped_file.get_extension() == "spyaml":
			_open_spyaml_file(dropped_file)
	pass

func _load_template_yaml():
	var _path : String = template_folder_directory+"/"+template_selector.selected+".yaml"
	_open_yaml_file(_path)
	pass

func _open_spyaml_file(_path : String):
	if(_path.get_extension() == "spyaml"):
		var settings_file = FileAccess.open(_path, FileAccess.READ)
		var settings_dict : Dictionary = str_to_var(settings_file.get_as_text())
		settings_file.close()
		
		var game_to_open = settings_dict["game"]
		var yaml_path : String = template_folder_directory+"/"+game_to_open+".yaml"
		
		Settingload.settings = settings_dict
		
		if FileAccess.file_exists(yaml_path):
			_open_yaml_file(yaml_path,true)
			pass
		else:
			_show_load_settings_select_yaml()
	pass

func _open_yaml_file(_path : String, from_settings : bool = false):
	Settingload.load_settings = from_settings
	current_yaml_template_dict = SPYaml.read(_path)
	
	last_save_file_name = template_selector.selected
	
	if(!current_yaml_template_dict.is_empty()):
		#print(current_yaml_template_dict)
		var file = FileAccess.open("user://debug_sp_yaml_dict_text.txt", FileAccess.WRITE)
		file.store_line(JSON.stringify(current_yaml_template_dict))
		file.close()
		_reset_ui_items()
		options_creator._reset()
		
		requirements_tooltip.visible = true
		var created_options = false
		
		if current_yaml_template_dict.has("file_options") and current_yaml_template_dict.has("randomizer_options"):
			if current_yaml_template_dict["randomizer_options"].has("options"):
				if current_yaml_template_dict["randomizer_options"]["options"].has("value"):
					_enable_save_buttons()
					_set_topbar_items()
					_create_options()
					save_settings_button.disabled = false
					created_options = true

		if !created_options:
			game_name_label.text = "Game: [color=#f38ba8]invalid yaml [b]₍^- ˕ -^₎⟆[/b][/color]"
			description_box.text = "the given yaml was invalid. are you trying to open an archipelago yaml or spyaml options file?"
			requirements_tooltip.tooltip = "[color=#f38ba8]the given yaml was invalid. This tool only accepts archipelago yaml or spyaml option files.\n\nthere's 2 types of archipelago yaml files, of which only 1 type is allowed.\n\n[b]Allowed archipelago yaml files start with '# Q. What is this file?'[/b][/color]"
			pass
	pass

func _reset_ui_items():
	save_settings_button.disabled = true
	load_yaml_to_start_panel.visible = true
	save_yaml_button.disabled = true
	save_yaml_template_button.disabled = true
	game_name_label.text = "Game:"
	requirements_label.text = "Requirements:"
	description_box.text = ""

func _create_options():
	options_creator.createSections(current_yaml_template_dict["option_sections"])
	options_creator.createOptions(current_yaml_template_dict["randomizer_options"]["options"]["value"])

func _set_topbar_items():
	game_name_label.text = "Game: [color=cba6f7]"+ current_yaml_template_dict["file_options"]["game"] +"[/color]"
	if current_yaml_template_dict["file_options"].has("requires"):
		requirements_label.text = "Requirements: [color=cba6f7]" + str(current_yaml_template_dict["file_options"]["requires"].size())+"[/color]"
		_set_requirements_tooltip_items()
	load_yaml_to_start_panel.visible = false
	description_box.text = current_yaml_template_dict["file_options"]["description"].substr(0,current_yaml_template_dict["file_options"]["description"].length()-65).strip_edges()

func _set_requirements_tooltip_items():
	var full_string : String = ""
	for key in current_yaml_template_dict["file_options"]["requires"].keys():
		var current_value = current_yaml_template_dict["file_options"]["requires"][key]
		var current_line : String = "     ("
		if key == "version":
			current_line += "[color=#a6e3a1]- Archipelago version[/color]: " + current_value
		elif key == "game":
			var game_name : String = current_value.keys()[0]
			var world_version : String = current_value[game_name]
			current_line += "[color=#a6e3a1]- game[/color]: " + game_name + " [color=#a6e3a1]using world version[/color]: " + world_version
		else:
			current_line += str(current_yaml_template_dict["file_options"]["requires"][key])
		full_string += current_line
		full_string += "\n"
	var cat_message = "    /\n[color=#fab387][b]₍^. .^₎⟆[/b][/color]"
	requirements_tooltip.tooltip = full_string+cat_message

#region saving
func _enable_save_buttons():
	save_yaml_button.disabled = false
	save_yaml_template_button.disabled = false

func get_option_dict() -> Dictionary:
	var return_dict : Dictionary = {}
	
	for section in options_creator.sections:
		for option in options_creator.sections[section].child_options:
			var option_name = option.dictionary_name
			return_dict[option_name] = option.get_value()
	
	return return_dict

func get_option_setting_dict() -> Dictionary:
	var return_dict : Dictionary = {}
	
	for section in options_creator.sections:
		for option in options_creator.sections[section].child_options:
			var option_name = option.dictionary_name
			return_dict[option_name] = option.get_setting_value()
	
	return return_dict

func _save_yaml_popup():
	save_yaml_popup.title = "save yaml"
	
	save_yaml_popup.popup()
	if last_save_location != "":
		save_yaml_popup.current_dir = last_save_location
	else:
		if DirAccess.dir_exists_absolute(static_players_dir):
			save_yaml_popup.current_dir = static_players_dir
		else:
			save_yaml_popup.current_dir = "C://"
	if last_save_file_name != "":
		save_yaml_popup.current_file = last_save_file_name
	else:
		save_yaml_popup.current_file = current_yaml_template_dict["file_options"]["game"]

	
func _attempt_save_yaml(_path : String):
	last_save_location = _path.substr(0,_path.length()-save_yaml_popup.current_file.length())
	last_save_file_name = save_yaml_popup.current_file
	save.data["last_save_location"] = var_to_str(last_save_location)
	yaml_saved_to_text.text = "[color=a6e3a1]YAML saved to[/color]: [color=#89dceb]"+_path+"[/color]."
	_save()
	var final_dictionary : Dictionary = {}
	if player_name_field.text.strip_edges() != "":
		final_dictionary["name"] = player_name_field.text
	else:
		final_dictionary["name"] = save_yaml_popup.current_file.substr(0,save_yaml_popup.current_file.length()-5)
	final_dictionary["description"] = current_yaml_template_dict["file_options"]["description"]
	final_dictionary["game"] = current_yaml_template_dict["file_options"]["game"]
	final_dictionary[current_yaml_template_dict["file_options"]["game"]] = get_option_dict()
	#print(final_dictionary)
	var file = FileAccess.open(_path, FileAccess.WRITE)
	file.store_line(SPYaml.dict_to_yaml(final_dictionary))
	file.close()
	pass
#endregion
	
