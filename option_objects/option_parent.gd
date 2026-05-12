extends HBoxContainer
class_name OptionParent

enum TYPE{
	TOGGLE,
	RANGE,
	CHOICE,
	LIST,
	DICTIONARY,
	UNSUPORTED
}

var value : Variant
var label_width : float = 0
var description : String = "A system that can move progression earlier, to try and prevent the player from getting stuck and bored early.\n\nA lower setting means more getting stuck. A higher setting means less getting stuck.\n\nYou can define additional values between the minimum and maximum values.\nMinimum value is 0\nMaximum value is 99\n"
@export var option_label_area: HBoxContainer
@export var value_display_area : HBoxContainer
@export var editing_area : HBoxContainer
@export var button_area : HBoxContainer
@export var option_name_label : Label
@export var tooltip: TextureRect

var dictionary_name : String = ""

func set_option_name(_name : String):
	dictionary_name = _name
	var display_name = _name.replace('_',' ')
	display_name = Utilities.humanize_identifier(display_name)
	#display_name = Utilities.camel_to_words(display_name)
	option_name_label.text = display_name
	set_label_width()
	
func set_label_width():
	label_width = option_label_area.size.x

func create_tooltip():
	tooltip.tooltip = description

func remove_text_from_description(what: String):
	var first_index = description.find(what)
	var remove_text_length = what.length()
	var first_part = description.substr(0,first_index)
	var second_part = description.substr(first_index+remove_text_length,description.length())
	description = first_part + second_part

func color_part_of_description(what: String, color : Color):
	var hexcol = color.to_html(false)
	var color_text_length = what.length()
	var first_index = description.find(what)
	var first_part = description.substr(0,first_index)
	var second_part = description.substr(first_index,color_text_length)
	var third_part = description.substr(first_index+color_text_length,description.length())
	description = first_part+"[color="+hexcol+"]"+second_part+"[/color]"+third_part
	
func init(_data: Dictionary, option_name : String):
	pass
