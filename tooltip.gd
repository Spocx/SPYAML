extends PanelContainer

var opacity_tween : Tween = null
@onready var tooltip: PanelContainer = $"."
@onready var label: RichTextLabel = $RichTextLabel

var posto : Vector2

func _ready() -> void:
	size.y = 0
	toggle(false)

func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		posto = get_global_mouse_position() + Vector2(10,10)
		if (posto.x > get_viewport_rect().size.x-size.x):
			posto.x = get_global_mouse_position().x-size.x
		if (posto.y > get_viewport_rect().size.y-size.y):
			posto.y = get_global_mouse_position().y-size.y

func set_pos():
	posto = get_global_mouse_position() + Vector2(10,10)
	if (posto.x > get_viewport_rect().size.x-size.x):
		posto.x = get_global_mouse_position().x-size.x
	if (posto.y > get_viewport_rect().size.y-size.y):
		posto.y = get_global_mouse_position().y-size.y
	global_position = posto

func _process(delta: float) -> void:
	global_position = Utilities.exp_decay(global_position,posto,0.9,delta)

func set_tooltip(_text : String):
	size.y = 0
	label.text = _text
	size.y = 0

func toggle(on: bool):
	if on:
		show()
		set_pos()
		size.y = 0
		tween_opactiy(1.0)
	else:
		modulate.a = 1.0
		await tween_opactiy(0.0).finished
		hide()

func tween_opactiy(to : float):
	if opacity_tween: opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self,'modulate:a',to,0.1)
	return opacity_tween
