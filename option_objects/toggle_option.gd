extends OptionParent
class_name ToggleOption

@export var randomize_button : Button
@onready var customcheckbox: CustomCheckbox = $editingsection/customcheckbox
@onready var value_label: Label = $valuedisplaysection/value
var toggle_by_default = false

func _ready() -> void:
	randomize_button.pressed.connect(randomize_button_pressed)
	customcheckbox.value_changed.connect(value_changed)
	if(toggle_by_default):
		customcheckbox.call_deferred("toggle")
	
func value_changed(_value : bool):
	value = bool(_value)
	if _value:
		value_label.text = "on"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(166,227,161))
	else:
		value_label.text = "off"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(235,160,172))

#var enabled_tween : Tween
func randomize_button_pressed():
	#if enabled_tween:
	#	enabled_tween.kill()
	#enabled_tween = create_tween()
	#enabled_tween.set_ease(Tween.EASE_OUT)
	
	if randomize_button.button_pressed:
		customcheckbox.set_enabled(false)
		#enabled_tween.tween_property(value_label,"modulate:a",0.3,0.1)
		value_label.text = "random"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(137,220,235))
	else:
		customcheckbox.set_enabled(true)
		#enabled_tween.tween_property(value_label,"modulate:a",1,0.1)
		value_changed(value)

func create_tooltip():
	var tooltip_desc : String = description
	tooltip.tooltip = tooltip_desc
	pass
	
func init(data: Dictionary, option_name : String):
	description = data["description"]
	create_tooltip()
	if int(data["value"]["'true'"]) == 50:
		toggle_by_default = true
		pass
	value = false
	pass
