extends TextureRect

@export var container : PanelContainer
@export var scroll_container : ScrollContainer
@export var is_top : bool = true
@export var max_size : float = 48

func _process(_delta: float) -> void:
	if is_top:
		custom_minimum_size.y = min(48,abs(container.position.y))
	else:
		var max_scroll = max(0,container.size.y-scroll_container.size.y)
		custom_minimum_size.y = min(48,max_scroll-abs(container.position.y))
		pass
