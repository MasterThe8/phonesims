extends HBoxContainer

@export var is_right: bool = false

func _ready():
	$Spacer.visible = is_right

func set_text(text: String):
	$Bubble.get_node("Label").text = text
