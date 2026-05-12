extends VBoxContainer
class_name FoldableCustom

var open : bool = false

@onready var button: Button = $Button
@onready var content: MarginContainer = $folderanim/HBoxContainer/MarginContainer
@onready var content_list: VBoxContainer = $folderanim/HBoxContainer/MarginContainer/Content
@onready var folderanim: ScrollContainer = $folderanim
var folderanim_size_to : float = 0
@onready var label: Label = $Button/Label

@export_group("internal")
@export var icon_open : Texture2D
@export var icon_closed: Texture2D
@export var color_closed: Color
@export var color_open: Color

var child_options: Array[OptionParent]

func _ready() -> void:
	button.pressed.connect(fold)

func set_title(title : String):
	label.text = title

func fold():
	open = !open
	
	if open:
		button.icon = icon_open
		folderanim_size_to = content.size.y
		content.visible = true
		label.modulate = color_open
	else:
		button.icon = icon_closed
		folderanim_size_to = 0
		label.modulate = color_closed

func _process(delta: float) -> void:
	if abs(folderanim_size_to-folderanim.custom_minimum_size.y) > 1:
		folderanim.custom_minimum_size.y = Utilities.exp_decay(folderanim.custom_minimum_size.y,folderanim_size_to,0.8,delta)
	else:
		if folderanim.custom_minimum_size.y < 1:
			folderanim.custom_minimum_size.y = 0
			content.visible = false
		
func add_section_child(child):
	content_list.add_child(child)
	child_options.push_back(child)

func get_widest_label() -> float:
	var widest_label : float = 0
	for option in child_options:
		widest_label = max(widest_label,option.option_label_area.size.x)
	return widest_label

func get_widest_value() -> float:
	var widest_value : float = 0
	for option in child_options:
		widest_value = max(widest_value,option.value_display_area.size.x)
	return widest_value

func get_widest_edit() -> float:
	var widest_edit : float = 0
	for option in child_options:
		widest_edit = max(widest_edit,option.editing_area.size.x)
	return widest_edit

func get_widest_button() -> float:
	var widest_button : float = 0
	for option in child_options:
		widest_button = max(widest_button,option.button_area.size.x)
	return widest_button

func setSizes(_label : float, _value : float, _edit : float, _button : float):
	for option in child_options:
		option.option_label_area.custom_minimum_size.x = _label
		option.value_display_area.custom_minimum_size.x = _value
		option.editing_area.custom_minimum_size.x = _edit
		option.button_area.custom_minimum_size.x = _button
	pass

func sizeLabels():
	var widest_label : float = 0
	var widest_value : float = 0
	var widest_edit : float = 0
	var widest_button : float = 0
	for option in child_options:
		widest_label = max(widest_label,option.option_label_area.size.x)
		widest_value = max(widest_value,option.value_display_area.size.x)
		widest_edit = max(widest_edit,option.editing_area.size.x)
		widest_button = max(widest_button,option.button_area.size.x)
	
	for option in child_options:
		option.option_label_area.custom_minimum_size.x = widest_label
		option.value_display_area.custom_minimum_size.x = widest_value
		option.editing_area.custom_minimum_size.x = widest_edit
		option.button_area.custom_minimum_size.x = widest_button
	pass
