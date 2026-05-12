extends Control

const static_template_dir : String = "C:/ProgramData/Archipelago/Players/Templates"
const static_players_dir : String = "C:/ProgramData/Archipelago/Players"

@export_group("dialogs")
@export var template_folder_popup: FileDialog
@export var manual_yaml_select_popup: FileDialog
@export var save_yaml_popup: FileDialog

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

var current_yaml_template_dict : Dictionary

func _save():
	if(true):
		SaveLoad.saveData(save)

func _ready() -> void:
	_connect_signals()
	_check_template_folder_popup()
	
func _connect_signals():
	get_window().files_dropped.connect(_file_dropped)
	locate_template_folder_button.pressed.connect(_template_folder_popup)
	manual_yaml_select_popup.file_selected.connect(_manual_file_selected)
	manual_locate_button.pressed.connect(_manual_select_popup)
	template_folder_popup.dir_selected.connect(_template_folder_selected)
	load_template_button.pressed.connect(_load_template_yaml)
	save_yaml_button.pressed.connect(_save_yaml_popup)
	save_yaml_popup.file_selected.connect(_attempt_save_yaml)

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
	print("a")
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

func _file_dropped(_files):
	if(!template_folder_popup.visible && !manual_yaml_select_popup.visible && !save_yaml_popup.visible):
		var dropped_file : String = _files[0]
		if dropped_file.get_extension() == "yaml":
			_open_yaml_file(dropped_file)
	pass

func _load_template_yaml():
	var _path : String = template_folder_directory+"/"+template_selector.selected+".yaml"
	_open_yaml_file(_path)
	pass

func _open_yaml_file(_path : String):
	current_yaml_template_dict = SPYaml.read(_path)
	
	if(!current_yaml_template_dict.is_empty()):
		#print(current_yaml_template_dict)
		var file = FileAccess.open("user://debugyamltext.txt", FileAccess.WRITE)
		file.store_line(JSON.stringify(current_yaml_template_dict))
		file.close()
		_enable_save_buttons()
		_set_topbar_items()
		_create_options()
	pass

func _create_options():
	options_creator.createSections(current_yaml_template_dict["option_sections"])
	options_creator.createOptions(current_yaml_template_dict["randomizer_options"]["options"]["value"])

func _set_topbar_items():
	game_name_label.text = "Game: [color=cba6f7]"+ current_yaml_template_dict["file_options"]["game"] +"[/color]"
	requirements_label.text = "Requirements: [color=cba6f7]" + str(current_yaml_template_dict["file_options"]["requires"].size())+"[/color]"
	requirements_tooltip.visible = true
	_set_requirements_tooltip_items()
	load_yaml_to_start_panel.visible = false
	description_box.text = current_yaml_template_dict["file_options"]["description"].substr(0,current_yaml_template_dict["file_options"]["description"].length()-31).strip_edges()

func _set_requirements_tooltip_items():
	var full_string : String = ""
	var key_amount = current_yaml_template_dict["file_options"]["requires"].keys().size()
	var current_key_index = 0
	for key in current_yaml_template_dict["file_options"]["requires"].keys():
		var current_value = current_yaml_template_dict["file_options"]["requires"][key]
		if key == "version":
			full_string += "[color=#a6e3a1]- Archipelago version[/color]: " + current_value
		elif key == "game":
			var game_name : String = current_value.keys()[0]
			var world_version : String = current_value[game_name]
			full_string += "[color=#a6e3a1]- game[/color]: " + game_name + " [color=#a6e3a1]using world version[/color]: " + world_version
		else:
			full_string += str(current_yaml_template_dict["file_options"]["requires"][key])
		current_key_index += 1
		if current_key_index < key_amount:
			full_string += "\n"
	requirements_tooltip.tooltip = full_string

#region saving
func _enable_save_buttons():
	save_yaml_button.disabled = false
	save_yaml_template_button.disabled = false

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
	pass
#endregion
	
