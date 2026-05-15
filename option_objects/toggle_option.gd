extends OptionParent
class_name ToggleOption

@export var randomize_button : Button
@onready var customcheckbox: CustomCheckbox = $editingsection/customcheckbox
@onready var value_label: Label = $valuedisplaysection/value
@export var link_items: Array[Control]
var toggle_by_default = false

func _ready() -> void:
	randomize_button.pressed.connect(randomize_button_pressed)
	customcheckbox.value_changed.connect(value_changed)
	if(toggle_by_default):
		customcheckbox.call_deferred("toggle")
	
func value_changed(_value : bool):
	value = _value
	if _value:
		value_label.text = "on"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(166,227,161))
	else:
		value_label.text = "off"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(235,160,172))
	#print(value)

func hide_tooltip():
	tooltip.visible = false
	for i in link_items:
		i.visible = false

func randomize_button_pressed():
	
	if randomize_button.button_pressed:
		customcheckbox.set_enabled(false)
		value_label.text = "random"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(137,220,235))
	else:
		customcheckbox.set_enabled(true)
		value_changed(customcheckbox.on)

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	tooltip.tooltip = Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func get_value() -> Variant:
	return value if !randomize_button.button_pressed else [true,false].pick_random()

func set_on():
	toggle_by_default = true

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	if int(data["value"]["'true'"]) == 50:
		toggle_by_default = true
		pass
	value = "false"
	pass
