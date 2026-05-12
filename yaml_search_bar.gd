extends LineEdit

@export var item_container : VBoxContainer

func _ready() -> void:
	text_changed.connect(search)
	
func search(_value):
	var labels = item_container.get_children()
	
	for l in labels:
		l.visible = true
	
	if text.strip_edges() != "":
		for l in labels:
			l.visible = l.label.text.to_lower().contains(text.to_lower())
	
	for l in labels:
		if l.visible:
			return
	
	for l in labels:
		l.visible = true
