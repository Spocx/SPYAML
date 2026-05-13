extends HBoxContainer
class_name ListOptionItem

@export var label: Label
@export var remove_button : TextureButton
var owner_option : ListOption = null
var value : String = ""

func _ready() -> void:
	remove_button.pressed.connect(remove)

func set_value(_value : String):
	value = _value
	label.text = "- " + value

func remove():
	owner_option.remove_item(self)
	
func get_value() -> String:
	return value
