extends TextureRect

@export_multiline("tooltip")
var tooltip : String = ""
var app : Control

func _ready() -> void:
	mouse_entered.connect(entered)
	mouse_exited.connect(exited)
	app = get_tree().get_first_node_in_group("app")
	
func entered():
	app.tooltip.set_tooltip(tooltip)
	app.tooltip.toggle(true)
	pass

func exited():
	app.tooltip.toggle(false)
	pass
