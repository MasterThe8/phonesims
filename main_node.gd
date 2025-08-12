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
	# Store a reference to the StoryLoader before changing scenes
	var loader = story_loader
	
	# Create a timer before changing scenes
	var timer = get_tree().create_timer(0.5)
	
	# Change to the message scene
	get_tree().change_scene_to_file("res://home_message.tscn")
	
	# Use a deferred call to start the chapter after the scene change
	timer.timeout.connect(func():
		if loader:
			loader.start_chapter("chapter1")
	)