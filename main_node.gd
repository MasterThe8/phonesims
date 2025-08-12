extends Control


func _on_icon_message_pressed() -> void:
	get_tree().change_scene_to_file("res://home_message.tscn")
