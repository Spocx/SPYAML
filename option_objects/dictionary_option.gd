extends OptionParent
class_name DictionaryOption

@export var fold: FoldableCustom

func _ready() -> void:
	pass
	
func value_changed(_index : int):
	value = "value"

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	var disclaimer_text = "[color=#f38ba8][b]!! Dictionary edit is experimental. you'll need to know exactly what this setting expects to fill it in with the tool. If that is the case, feel free to use it. Sometimes the setting description describes expected input !![/b][/color]\n\n"
	tooltip.tooltip = disclaimer_text + Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	fold.set_title(display_name)
