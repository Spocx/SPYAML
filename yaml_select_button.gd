extends Button
class_name YAMLSelectButton

@onready var label: Label = $Label
var selector : YAMLSelector

func _ready() -> void:
	pressed.connect(select_label)

func select_label():
	selector.reset_buttons()
	selector.selected = label.text
	label.modulate = Color.from_rgba8(203,166,247)

func reset_button():
	label.modulate = Color.WHITE
