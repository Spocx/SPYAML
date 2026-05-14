extends OptionParent
class_name ListOption

const LIST_OPTION_ITEM = preload("res://option_objects/list_option_item.tscn")

enum LIST_TYPE{
	STRING,
	NUMBER
	}

@export var fold: FoldableCustom
@export var item_list : VBoxContainer
@export var input_field : LineEdit
@export var add_button : Button
@export var warning_label : Label
@export var type_select : OptionButton
@export var type_tooltip : TextureRect
@export var clear_list_button : Button

@export var tooltip_spacer: Control
@export var link_items: Array[Control]

var items : Array[ListOptionItem]
var warning_label_timer : float = 0
var list_type : LIST_TYPE = LIST_TYPE.STRING

func hide_tooltip():
	tooltip.visible = false
	tooltip_spacer.visible = false
	for i in link_items:
		i.visible = false

func _ready() -> void:
	type_select.item_selected.connect(select_list_type)
	add_button.pressed.connect(add_item_from_button)
	input_field.text_submitted.connect(add_item)
	clear_list_button.pressed.connect(clear_list)
	pass

func clear_list():
	for item in items:
		item.queue_free()
	items.clear()

func select_list_type(_selected: int):
	match _selected:
		0:
			list_type = LIST_TYPE.STRING
		1:
			list_type = LIST_TYPE.NUMBER
			validate_items()
	pass

func validate_items():
	var new_items : Array[int]
	for item in items:
		if !item.get_value().is_valid_int():
			item.queue_free()
		else:
			new_items.push_back(items.find(item))
	var new_list : Array[ListOptionItem]
	for n in new_items:
		new_list.push_back(items[n])
	items = new_list
	pass

func is_null(_value):
	if _value == null:
		return false
	else:
		return true

func _process(delta: float) -> void:
	if warning_label.visible:
		warning_label_timer -= delta
		if warning_label_timer <= 0:
			warning_label.visible = false

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	var disclaimer_text = "[color=#f38ba8][b]!! List edit is experimental. You'll need to understand what this setting expects. there is no autofill for available items. If you know what you're doing you're free to use this setting though. Sometimes the setting description describes expected input !![/b][/color]\n\n"
	tooltip.tooltip = disclaimer_text+Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	fold.set_title(display_name)
	
	var _type : LIST_TYPE = LIST_TYPE.NUMBER

	for _value in data["value"]["list"]:
		if _value is not int:
			_type = LIST_TYPE.STRING
			break
			
	if data["value"]["list"].size() == 0:
		_type = LIST_TYPE.STRING
	
	list_type = _type
	
	type_select.selected = _type
	
	for _value in data["value"]["list"]:
		var _v = str(_value).strip_edges()
		add_item(_v)
		
	if is_preset_string_list():
		type_select.disabled = true
		type_tooltip.tooltip += "\n\n[color=#a6e3a1][b]This is a common archipelago option, list value type has been locked in for you.[/b][/color]"

func get_value() -> String:
	match list_type:
		LIST_TYPE.STRING:
			var values : Array[String]
			for item in items:
				values.push_back(item.get_value())
			return str(values)
		LIST_TYPE.NUMBER:
			var values : Array[int]
			for item in items:
				values.push_back(int(item.get_value()))
			return str(values)
	return "[]"

func add_item_from_button():
	add_item(input_field.text)

func add_item(_item):
	var _item_name : String = _item.strip_edges() 
	
	if _item_name == "":
		show_warning("item name can not be empty")
		return
		
	if has_item(_item_name):
		show_warning("item already in list")
		return
	
	if list_type == LIST_TYPE.NUMBER:
		if !_item_name.is_valid_int():
			show_warning("item is not a number")
			return
	
	var new_item : ListOptionItem = LIST_OPTION_ITEM.instantiate()
	item_list.add_child(new_item)
	items.push_back(new_item)
	new_item.set_value(_item_name)
	new_item.owner_option = self
	input_field.clear()
	pass

func has_item(_item : String) -> bool:
	for item in items:
		if item.get_value() == _item:
			return true
	return false

func remove_item(_item : ListOptionItem):
	var index = items.find(_item)
	if index != -1:
		items.remove_at(index)
		_item.queue_free()
	pass

func show_warning(_text : String):
	warning_label.text = _text
	warning_label.visible = true
	warning_label_timer = 3
	pass

func is_preset_string_list() -> bool:
	var items_locations_lists : Array[String] = [
		"local_items",
		"non_local_items",
		"start_hints",
		"start_location_hints",
		"exclude_locations",
		"priority_locations",
		"item_links",
		"plando_items"
	]
	
	for i in items_locations_lists:
		if dictionary_name == i:
			return true
	
	return false
