extends OptionParent
class_name DictionaryTextOption

@export var value_label: Label
@export var line_edit: LineEdit


func get_value() -> Variant:
	return line_edit.text

func get_setting_value() -> Variant:
	return ["dict_text",line_edit.text]
	
func load_setting_through_dict(data):
	line_edit.text = data[1]
	pass
