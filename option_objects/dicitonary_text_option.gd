extends OptionParent
class_name DictionaryTextOption

@export var value_label: Label
@export var line_edit: LineEdit


func get_value() -> Variant:
	return line_edit.text
