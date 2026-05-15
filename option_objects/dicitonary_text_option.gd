extends OptionParent
class_name DictionaryTextOption

@onready var value_label: Label = $valuedisplaysection/value
@onready var line_edit: LineEdit = $editingsection/LineEdit


func get_value() -> Variant:
	return line_edit.text
