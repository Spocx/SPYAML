extends VBoxContainer
class_name YAMLSelector

const YAML_SELECT_BUTTON = preload("uid://ciohpm7j11hvp")

var selected : String = ""
var buttons : Array[YAMLSelectButton]

func _ready() -> void:
	for i in 20:
		spawn_button("hello")

func reset_buttons():
	for b in buttons:
		b.reset_button()
	pass

func spawn_button(_name : String):
	var new_button = YAML_SELECT_BUTTON.instantiate()
	add_child(new_button)
	new_button.selector = self
	new_button.label.text = _name
	buttons.push_back(new_button)
	pass

func remove_buttons():
	for b in buttons:
		b.queue_free()
	buttons.clear()
	pass
