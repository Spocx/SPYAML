extends PanelContainer
class_name CustomCheckbox

@export var color_on : Color
@export var color_off : Color

var on = false
var size_to : float
var size_lerp : float = 0

@onready var slider: NinePatchRect = $bg/slider
@onready var button: Button = $bg/Button
@onready var knob: NinePatchRect = $bg/slider/knob
@onready var bg: NinePatchRect = $bg

var bg_tween : Tween
var size_tween : Tween
var enabled : bool = true

signal value_changed(value: bool)

func _ready() -> void:
	button.pressed.connect(toggle)
	button.mouse_entered.connect(hover)
	button.mouse_exited.connect(unhover)

func hover():
	if(enabled):
		knob.scale = Vector2.ONE*1.1

func unhover():
	knob.scale = Vector2.ONE

var enabled_tween : Tween

func set_enabled(_enabled : bool):
	enabled = _enabled
	
	if enabled_tween:
		enabled_tween.kill()
	enabled_tween = create_tween()
	enabled_tween.set_ease(Tween.EASE_OUT)
	
	if(enabled):
		enabled_tween.tween_property(self,"modulate:a",1,0.1)
	else:
		enabled_tween.tween_property(self,"modulate:a",0.1,0.1)

func toggle():
	if(enabled):
		on = !on
		if size_tween:
			size_tween.kill()
		size_tween = create_tween()
		size_tween.set_ease(Tween.EASE_OUT)
		
		
		if bg_tween:
			bg_tween.kill()
		bg_tween = create_tween()
		bg_tween.set_ease(Tween.EASE_OUT)
		
		if on:
			size_tween.tween_property(slider, "size:x", button.size.x,0.1)
			bg_tween.tween_property(bg,"self_modulate",color_on,0.1)
		else:
			size_tween.tween_property(slider, "size:x", button.size.x/2,0.1)
			bg_tween.tween_property(bg,"self_modulate",color_off,0.1)
		
		value_changed.emit(on)
