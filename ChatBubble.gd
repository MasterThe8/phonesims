extends HBoxContainer

@export var is_right: bool = false
@export var bubble_color: Color = Color(0.12, 0.51, 0.96, 1.0)
@export var bubble_radius: int = 10

func _ready():
	$Spacer.visible = is_right
	_apply_bubble_style()

func set_text(text: String):
	$MarginContainer/Bubble/Label.text = text

func _apply_bubble_style():
	var style = StyleBoxFlat.new()
	style.bg_color = bubble_color
	style.corner_radius_top_left = bubble_radius
	style.corner_radius_top_right = bubble_radius
	style.corner_radius_bottom_left = bubble_radius if is_right else bubble_radius
	style.corner_radius_bottom_right = bubble_radius if not is_right else bubble_radius
	
	$MarginContainer/Bubble.add_theme_stylebox_override("panel", style)

# Set custom padding for the bubble
func set_bubble_padding(left: int, top: int, right: int = 12, bottom: int = 8) -> void:
	var style = $MarginContainer/Bubble.get_theme_stylebox("panel").duplicate()
	style.content_margin_left = left
	style.content_margin_top = top
	style.content_margin_right = right
	style.content_margin_bottom = bottom
	
	$MarginContainer/Bubble.add_theme_stylebox_override("panel", style)

# Set custom color for the bubble
func set_bubble_color(color: Color) -> void:
	bubble_color = color
	_apply_bubble_style()

# Set custom corner radius for the bubble
func set_bubble_radius(radius: int) -> void:
	bubble_radius = radius
	_apply_bubble_style()