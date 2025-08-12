extends Node

# StoryLoader
# This script handles loading and managing different story chapters

# References to chapter scripts
var chapter1: Node = null

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize chapter scripts
	_initialize_chapters()

# Initialize all chapter scripts
func _initialize_chapters():
	# Create Chapter1 instance
	chapter1 = load("res://Chapter1.gd").new()
	add_child(chapter1)

# Start a specific chapter
func start_chapter(chapter_name: String):
	match chapter_name:
		"chapter1":
			if chapter1:
				chapter1.start_chapter()
		_:
			push_error("Unknown chapter: " + chapter_name)

# Get a reference to a specific chapter
func get_chapter(chapter_name: String) -> Node:
	match chapter_name:
		"chapter1":
			return chapter1
		_:
			push_error("Unknown chapter: " + chapter_name)
			return null

# Continue story after a specific choice in a specific chapter
func continue_after_choice(chapter_name: String, choice_id: String, option_index: int):
	var chapter = get_chapter(chapter_name)
	if chapter:
		var method_name = "continue_after_" + choice_id + "_option_" + str(option_index)
		if chapter.has_method(method_name):
			chapter.call(method_name)
		else:
			push_warning("Method not found: " + method_name + " in chapter " + chapter_name)