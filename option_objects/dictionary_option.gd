extends OptionParent
class_name DictionaryOption

const LIST_OPTION = preload("res://option_objects/list_option.tscn")
const DICTIONARY_OPTION = preload("res://option_objects/dictionary_option.tscn")
const TOGGLE_OPTION = preload("res://option_objects/toggle_option.tscn")
const DICTIONARY_TRASH_BUTTON = preload("res://option_objects/dictionary_trash_button.tscn")
const DICTIONARY_NUMBER_OPTION = preload("res://option_objects/dictionary_number_option.tscn")
const DICTIONARY_TEXT_OPTION = preload("res://option_objects/dictionary_text_option.tscn")

@export var fold: FoldableCustom
@export var type_selector : OptionButton
@export var key_input : LineEdit
@export var add_button : Button
@export var warning_label : Label
@export var type_tooltip : TextureRect
@export var clear_dictionary_button : Button
@export var trash_icon_list : VBoxContainer

@export var tooltip_spacer: Control
@export var link_items: Array[Control]

var c_index : int = 0
var warning_label_timer : float = 0

func hide_tooltip():
	tooltip.visible = false
	tooltip_spacer.visible = false
	for i in link_items:
		i.visible = false

func _ready() -> void:
	clear_dictionary_button.pressed.connect(clear_dictionary)
	add_button.pressed.connect(add_item_from_button)
	key_input.text_submitted.connect(add_item)
	pass

func _process(delta: float) -> void:
	for trash in trash_icon_list.get_children():
		var _index = trash.get_index()
		trash.custom_minimum_size.y = fold.child_options[_index].size.y
	
	if warning_label.visible:
		warning_label_timer -= delta
		if warning_label_timer <= 0:
			warning_label.visible = false

func clear_dictionary():
	for item in fold.child_options:
		item.queue_free()
	fold.child_options.clear()
	for child in trash_icon_list.get_children():
		child.queue_free()
	c_index = 0

func remove_item(trash_icon: DictionaryTrashButton):
	var _index = trash_icon.get_index()
	fold.child_options[_index].queue_free()
	fold.child_options.remove_at(_index)
	trash_icon.queue_free()
	pass

func value_changed(_index : int):
	value = "value"

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	var disclaimer_text = "[color=#f38ba8][b]!! Dictionary edit is experimental. you'll need to know exactly what this setting expects to fill it in with the tool. If that is the case, feel free to use it. Sometimes the setting description describes expected input !![/b][/color]\n\n"
	tooltip.tooltip = disclaimer_text + Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func show_warning(_text : String):
	warning_label.text = _text
	warning_label.visible = true
	warning_label_timer = 3
	pass


func add_item_from_button():
	add_item(0)
	pass

func add_item(_value, _force_type: String = "", _force_name : String = "", _default_value : Variant = null):
	var _item_type : String = type_selector.get_item_text(type_selector.selected)
	var _item_name : String = key_input.text.strip_edges()
	
	if _force_type != "":
		_item_type = _force_type
	if _force_name != "":
		_item_name = _force_name
		
	if _item_name == "":
		show_warning("item name can not be empty")
		return
		
	if has_item(_item_name):
		show_warning("item already in list")
		return
	
	var option : OptionParent
	var trash_button : DictionaryTrashButton = DICTIONARY_TRASH_BUTTON.instantiate()
	trash_button.owner_dict = self
	match _item_type:
		"string":
			option = DICTIONARY_TEXT_OPTION.instantiate()
			option.dictionary_name = _item_name
			option.display_name = _item_name
			option.option_name_label.text = _item_name
			option.set_label_width()
			fold.add_section_child(option)
			
			if _default_value != null:
				option.line_edit.text = _default_value
			pass
		"int":
			option = DICTIONARY_NUMBER_OPTION.instantiate()
			option.dictionary_name = _item_name
			option.display_name = _item_name
			option.option_name_label.text = _item_name
			option.set_label_width()
			fold.add_section_child(option)
			
			if _default_value != null:
				option.spin_box.value = _default_value
			pass
		
		"bool":
			option = TOGGLE_OPTION.instantiate()
			option.hide_tooltip()
			option.dictionary_name = _item_name
			option.display_name = _item_name
			option.option_name_label.text = _item_name
			option.set_label_width()
			fold.add_section_child(option)
			
			if _default_value != null:
				if _default_value == true:
					option.set_on()
			pass
			
		"list":
			option = LIST_OPTION.instantiate()
			option.hide_tooltip()
			option.dictionary_name = _item_name
			option.display_name = _item_name
			option.option_name_label.text = _item_name
			option.fold.set_title(option.display_name)
			fold.add_section_child(option)
			
			if _default_value != null:
				option.add_items_from_array(_default_value)
			pass
			
		"dictionary":
			option = DICTIONARY_OPTION.instantiate()
			option.hide_tooltip()
			option.dictionary_name = _item_name
			option.display_name = _item_name
			option.option_name_label.text = _item_name
			option.fold.set_title(option.display_name)
			fold.add_section_child(option)
			
			if _default_value != null:
				option.init_values(_default_value)
			pass
	option.o_index = c_index
	c_index += 1
	trash_icon_list.add_child(trash_button)
	key_input.text = ""
	fold.call_deferred("reorder_children")
	call_deferred("section_option_labels_resize")

func section_option_labels_resize():
	var widest_label  : float = fold.get_widest_label()
	var widest_value  : float = fold.get_widest_value()
	var widest_edit   : float = fold.get_widest_edit()
	var widest_button : float = fold.get_widest_button()
	fold.setSizes(widest_label,widest_value,widest_edit,widest_button)

func has_item(_item : String) -> bool:
	for item in fold.child_options:
		if item.display_name == _item:
			return true
	return false

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	fold.set_title(display_name)
	if is_preset_dict():
		type_selector.selected = 1
		type_selector.disabled = true
		type_tooltip.tooltip += "\n\n[color=#a6e3a1][b]This is a common archipelago option, dictionary value type has been locked in for you.[/b][/color]"
		pass
	init_values(data["value"])

func init_values(value_data: Dictionary):
	for key in value_data:
		var _value = value_data[key]
		if _value is Array:
			add_item(0,"list",key,value_data[key])
		if _value is Dictionary:
			if value_data[key].has("value"):
				add_item(0,"dictionary",key,value_data[key]["value"])
			else:
				add_item(0,"dictionary",key)
		if _value is int:
			add_item(0,"int",key,value_data[key])
		if _value is String:
			add_item(0,"string",key,value_data[key])
		if _value is bool:
			add_item(0,"bool",key,value_data[key])
	pass

func get_value() -> Variant:
	var dict : Dictionary = {}
	for item in fold.child_options:
		dict[item.dictionary_name] = item.get_value()
	return dict

func is_preset_dict():
	var items_locations_lists : Array[String] = [
	"start_inventory",
	"start_inventory_from_pool",
	]
	
	for i in items_locations_lists:
		if dictionary_name == i:
			return true
	
	return false
