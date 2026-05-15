extends OptionParent
class_name DictionaryNumberOption

@export var randomize_button : Button
@export var value_label: Label
@export var spin_box: SpinBox
@export var _min: SpinBox
@export var _max: SpinBox


func _ready() -> void:
	randomize_button.pressed.connect(randomize_button_pressed)

var enabled_tween : Tween
func randomize_button_pressed():
	if enabled_tween:
		enabled_tween.kill()
	enabled_tween = create_tween()
	enabled_tween.set_ease(Tween.EASE_OUT)
	
	if randomize_button.button_pressed:
		value_label.text = "random"
		enabled_tween.tween_property(spin_box,"modulate:a",0.3,0.1)
		spin_box.editable = false
		_min.visible = true
		_max.visible = true
	else:
		value_label.text = ""
		enabled_tween.tween_property(spin_box,"modulate:a",1.0,0.1)
		spin_box.editable = true
		_min.visible = false
		_max.visible = false
		pass

func get_value() -> Variant:
	return int(spin_box.value) if !randomize_button.button_pressed else randi_range(int(_min.value),int(_max.value))
