extends OptionParent
class_name RangeOption

@export var slider : HSlider
@export var value_label : Label
@export var randomize_button : Button

var savemod : Color

func _ready() -> void:
	slider.value_changed.connect(value_changed)
	randomize_button.pressed.connect(randomize_button_pressed)
	savemod = value_label.get_theme_color("font_color")
	
	if Settingload.load_settings:
		load_setting()
	
func load_setting():
	if Settingload.settings["settings"].has(dictionary_name):
		slider.value = Settingload.settings["settings"][dictionary_name][2]
		if Settingload.settings["settings"][dictionary_name][1]:
			randomize_button.button_pressed = true
			randomize_button_pressed()
		
func value_changed(_value : float):
	value = int(_value)
	value_label.text = str(value)

var enabled_tween_slider : Tween
func randomize_button_pressed():
	
	if enabled_tween_slider:
		enabled_tween_slider.kill()
	enabled_tween_slider = create_tween()
	enabled_tween_slider.set_ease(Tween.EASE_OUT)
	
	if randomize_button.button_pressed:
		slider.editable = false
		slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		value_label.text = "random"
		value_label.add_theme_color_override("font_color",Color.from_rgba8(137,220,235))
		enabled_tween_slider.tween_property(slider,"modulate:a",0.3,0.1)
	else:
		slider.editable = true
		slider.mouse_filter = Control.MOUSE_FILTER_STOP
		value_label.text = str(value)
		value_label.add_theme_color_override("font_color",savemod)
		enabled_tween_slider.tween_property(slider,"modulate:a",1,0.1)


func create_tooltip():
	var first_index = description.find("\n\nYou can define additional values between the minimum and maximum values.")
	var tooltip_desc : String = description.substr(0,first_index)
	attempt_set_url(tooltip_desc)
	tooltip.tooltip = Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func get_value() -> Variant:
	return value if !randomize_button.button_pressed else randi_range(int(slider.min_value),int(slider.max_value))

func get_setting_value() -> Variant:
	return ["range",randomize_button.button_pressed, value]

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	var first_index = description.find("\n\nYou can define additional values between the minimum and maximum values.")
	var find_vals_str = description.substr(first_index,description.length())
	var min_val_start_index : int = find_vals_str.find("Minimum value is")
	var min_val_end_index : int = find_vals_str.substr(min_val_start_index,find_vals_str.length()).find("\n")
	var min_val_string = find_vals_str.substr(min_val_start_index,min_val_end_index)
	var min_string = min_val_string.replace("Minimum value is","").strip_edges()
	var v_min : int = int(min_string)
	
	var max_val_start_index : int = find_vals_str.find("Maximum value is")
	var max_val_string = find_vals_str.substr(max_val_start_index,find_vals_str.length())
	var max_string = max_val_string.replace("Maximum value is","").strip_edges()
	var v_max : int = int(max_string)
	
	slider.min_value = v_min
	slider.max_value = v_max
	
	if option_name == "progression_balancing":
		slider.value = 50
	else:
		if(data["value"].keys()[0].is_valid_int()):
			slider.value = int(data["value"].keys()[0])
	value_changed(slider.value)
	
	
	pass
