extends HBoxContainer
class_name DictionaryTrashButton

@export var button : TextureButton
var owner_dict : DictionaryOption

func _ready() -> void:
	button.pressed.connect(remove_item)
	
func remove_item():
	owner_dict.remove_item(self)
