extends VBoxContainer
class_name FoldableCustom

var open : bool = false

@export var button: Button
@export var content: MarginContainer
@export var content_list: VBoxContainer
@export var folderanim: ScrollContainer
var folderanim_size_to : float = 0
@export var label: Label

@export_group("internal")
@export var icon_open : Texture2D
@export var icon_closed: Texture2D
@export var color_closed: Color
@export var color_open: Color

var child_options: Array[OptionParent]

var list_dict_options : int = 0

func _ready() -> void:
	button.pressed.connect(fold)

func set_title(title : String):
	label.text = title

func fold():
	open = !open
	
	if open:
		button.icon = icon_open
		content.visible = true
		label.modulate = color_open
	else:
		button.icon = icon_closed
		label.modulate = color_closed

func _process(delta: float) -> void:
	if open:
		folderanim_size_to = content.size.y
	else:
		folderanim_size_to = 0
		
	if abs(folderanim_size_to-folderanim.custom_minimum_size.y) > 1:
		folderanim.custom_minimum_size.y = Utilities.exp_decay(folderanim.custom_minimum_size.y,folderanim_size_to,0.8,delta)
	else:
		if folderanim.custom_minimum_size.y < 1:
			folderanim.custom_minimum_size.y = 0
			content.visible = false
		
func add_section_child(child : OptionParent):
	content_list.add_child(child)
	child_options.push_back(child)

func reorder_children():
	for option in child_options:
		if option is ListOption or option is DictionaryOption:
			content_list.move_child(option,content_list.get_child_count())
	pass

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
