extends OptionParent
class_name ChoiceOption

@export var option_button : OptionButton
@export var value_label : Label
@export var randomize_button : Button

var savemod : Color
var actual_values : Array[String]

func _ready() -> void:
	randomize_button.pressed.connect(randomize_button_pressed)
	value_label.add_theme_color_override("font_color",Color.from_rgba8(137,220,235))
	option_button.item_selected.connect(value_changed)
	
	if Settingload.load_settings:
		load_setting()

func load_setting():
	if Settingload.settings["settings"].has(dictionary_name):
		value = Settingload.settings["settings"][dictionary_name][2]
		option_button.selected = actual_values.find(value)
		if Settingload.settings["settings"][dictionary_name][1]:
			randomize_button.button_pressed = true
			randomize_button_pressed()

func value_changed(_index : int):
	value = actual_values[_index]

var enabled_tween_slider : Tween
func randomize_button_pressed():
	
	if enabled_tween_slider:
		enabled_tween_slider.kill()
	enabled_tween_slider = create_tween()
	enabled_tween_slider.set_ease(Tween.EASE_OUT)
	
	if randomize_button.button_pressed:
		option_button.disabled = true
		option_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		value_label.text = "random"
		enabled_tween_slider.tween_property(option_button,"modulate:a",0.3,0.1)
	else:
		option_button.disabled = false
		option_button.mouse_filter = Control.MOUSE_FILTER_STOP
		value_label.text = ""
		enabled_tween_slider.tween_property(option_button,"modulate:a",1,0.1)
	

func create_tooltip():
	var tooltip_desc : String = description
	attempt_set_url(tooltip_desc)
	tooltip.tooltip = Utilities.markdown_bold_to_bbcode(tooltip_desc)
	pass

func get_value() -> Variant:
	return value if !randomize_button.button_pressed else actual_values.pick_random()

func get_setting_value() -> Variant:
	return ["choice", randomize_button.button_pressed, value]

func init(data: Dictionary, option_name : String):
	super(data,option_name)
	var selected_index : int = 0
	for key in data["value"]:
		actual_values.push_back(key)
		option_button.add_item(key.replace("'","").replace("_"," "))
		if data["value"][key] == 50:
			selected_index = option_button.item_count-1
	option_button.selected = selected_index
	value_changed(selected_index)
	pass
