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
	# Change to the message scene
	get_tree().change_scene_to_file("res://home_message.tscn")
	
	# Start Chapter 1 after a short delay
	await get_tree().create_timer(0.5).timeout
	if story_loader:
		story_loader.start_chapter("chapter1")