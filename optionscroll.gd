extends ScrollBar

@export var scroll_container: ScrollContainer
@export var cparent : PanelContainer
@export var seperator : VSeparator
@export var seperatorh : HSeparator
@export var is_vertical : bool = true

var internal_bar : ScrollBar

func _process(_delta: float) -> void:
	if(max_value == page):
		cparent.visible = false
		if seperator != null:
			seperator.visible = false
		if seperatorh != null:
			seperatorh.visible = false
	else:
		cparent.visible = true
		if seperator != null:
			seperator.visible = true
		if seperatorh != null:
			seperatorh.visible = true

func _ready():
	if is_vertical:
		internal_bar = scroll_container.get_v_scroll_bar()
	else:
		internal_bar = scroll_container.get_h_scroll_bar()

	# Sync external -> internal
	value_changed.connect(my_val_changed)

	# Sync internal -> external
	internal_bar.scrolling.connect(set_svalue)
	
	internal_bar.value_changed.connect(set_svalue)

	# Copy scrollbar settings
	min_value = internal_bar.min_value
	max_value = internal_bar.max_value
	page = internal_bar.page
	step = internal_bar.step

	# Update settings if content changes
	internal_bar.changed.connect(_update_external_scrollbar)

func my_val_changed(_value: float = 0.0):
	internal_bar.value = value
	
func set_svalue(_value: float = 0.0):
	value = internal_bar.value

func _update_external_scrollbar():

	min_value = internal_bar.min_value
	max_value = internal_bar.max_value
	page = internal_bar.page
