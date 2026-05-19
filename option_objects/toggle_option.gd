extends OptionParent
class_name ToggleOption

@export var randomize_button : Button
@onready var customcheckbox: CustomCheckbox = $editingsection/customcheckbox
@onready var value_label: Label = $valuedisplaysection/value
@export var link_items: Array[Control]
var toggle_by_default = false
var spawned_by_dict : bool = false

func _ready() -> void:
	randomize_button.pressed.connect(randomize_button_pressed)
	customcheckbox.value_changed.connect(value_changed)
	value = false
	
	if !spawned_by_dict:
		if Settingload.load_settings:
			load_setting()
	
	if(toggle_by_default):
		customcheckbox.call_deferred("toggle")
	reset_default_button.pressed.connect(reset_value)
	reset_default_button.visible = false
	
func reset_value():
	
	randomize_button.button_pressed = false
	randomize_button_pressed()
	if init_value:
		customcheckbox.call_deferred("set_on")
	else:
		customcheckbox.call_deferred("set_off")
	reset_default_button.visible = false
	pass

func load_setting():
	if Settingload.settings["settings"].has(dictionary_name):
		value_changed(Settingload.settings["settings"][dictionary_name][2])
		if value:
			toggle_by_default = true
		if Settingload.settings["settings"][dictionary_name][1]:
			randomize_button.button_pressed = true
			call_deferred("randomize_button_pressed")

func load_setting_through_dict(data):
	randomize_button.button_pressed = false
	if data[2]:
		customcheckbox.set_on()
	else:
		customcheckbox.set_off()
	randomize_button.button_pressed = data[1]
	randomize_button_pressed()
	#	return ["toggle" ,randomize_button.button_pressed, value]
	
	pass

func value_changed(_value : bool):
	value = _value
	if _value:
		value_label.text = "on"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(166,227,161))
	else:
		value_label.text = "off"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(235,160,172))
	if value != init_value || randomize_button.button_pressed:
		if ! spawned_by_dict:
			reset_default_button.visible = true

func hide_tooltip():
	tooltip.visible = false
	for i in link_items:
		i.visible = false

func randomize_button_pressed():
	
	if randomize_button.button_pressed:
		customcheckbox.call_deferred("set_enabled",false)
		value_label.text = "random"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(137,220,235))
	else:
		customcheckbox.call_deferred("set_enabled",true)
		value_changed(customcheckbox.on)
	if value != init_value || randomize_button.button_pressed:
		if ! spawned_by_dict:
			reset_default_button.visible = true

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	tooltip.tooltip = Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func get_value() -> Variant:
	return value if !randomize_button.button_pressed else [true,false].pick_random()

func get_setting_value() -> Variant:
	return ["toggle" ,randomize_button.button_pressed, value]

func set_on():
	toggle_by_default = true

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	if int(data["value"]["'true'"]) == 50:
		toggle_by_default = true
		pass
	value = false
	init_value = toggle_by_default
	reset_default_button.visible = false
	pass
