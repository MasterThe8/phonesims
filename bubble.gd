extends HBoxContainer

@onready var bubble := $Bubble  # PanelContainer

func _ready():
	# contoh set margin left 16 dan top 10
	set_bubble_padding(16, 10, 12, 8)

func set_bubble_padding(left: int, top: int, right: int = 12, bottom: int = 8) -> void:
	var style := StyleBoxFlat.new()
	style.content_margin_left = left
	style.content_margin_top = top
	style.content_margin_right = right
	style.content_margin_bottom = bottom
	# (opsional) atur warna / corner radius	style.bg_color = Color(0.92, 0.96, 1.0)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 4

	# override style "panel" pada PanelContainer
	bubble.add_theme_stylebox_override("panel", style)
