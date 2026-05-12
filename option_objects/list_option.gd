extends OptionParent
class_name ListOption

@export var fold: FoldableCustom

func _ready() -> void:
	pass
	
func value_changed(_index : int):
	value = "value"

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	var disclaimer_text = "[color=#f38ba8][b]!! List edit is experimental. You'll need to understand what this setting expects. there is no autofill for available items. If you know what you're doing you're free to use this setting though. Sometimes the setting description describes expected input !![/b][/color]\n\n"
	tooltip.tooltip = disclaimer_text+Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	fold.set_title(option_name)
