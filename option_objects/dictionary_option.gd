extends OptionParent
class_name DictionaryOption

const LIST_OPTION = preload("res://option_objects/list_option.tscn")
const DICTIONARY_OPTION = preload("res://option_objects/dictionary_option.tscn")

@export var fold: FoldableCustom
@export var type_selector : OptionButton
@export var key_input : LineEdit
@export var add_button : Button
@export var warning_label : Label
@export var clear_dictionary_button : Button
@export var item_list : VBoxContainer

@export var tooltip_spacer: Control
@export var link_items: Array[Control]

var items : Array[OptionParent]
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
	if warning_label.visible:
		warning_label_timer -= delta
		if warning_label_timer <= 0:
			warning_label.visible = false

func clear_dictionary():
	for item in items:
		item.queue_free()
	items.clear()
	
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

func add_item(_value):
	match type_selector.get_item_text(type_selector.selected):
		"string":
			pass
		
		"int":
			pass
			
		"list":
			var option = LIST_OPTION.instantiate()
			option.hide_tooltip()
			item_list.add_child(option)
			pass
			
		"dictionary":
			var option = DICTIONARY_OPTION.instantiate()
			option.hide_tooltip()
			item_list.add_child(option)
			pass

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	fold.set_title(display_name)
