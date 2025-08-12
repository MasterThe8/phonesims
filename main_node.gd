extends Control

# Reference to the StoryLoader
var story_loader = null

func _ready():
	# Initialize StoryLoader if it doesn't exist
	if not has_node("/root/StoryLoader"):
		var story_loader_script = load("res://StoryLoader.gd")
		story_loader = story_loader_script.new()
		story_loader.name = "StoryLoader"
		get_tree().root.add_child(story_loader)
	else:
		story_loader = get_node("/root/StoryLoader")

func _on_icon_message_pressed() -> void:
	# Change to the HomeMessage scene (contacts list)
	get_tree().change_scene_to_file("res://HomeMessage.tscn")