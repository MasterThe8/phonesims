extends Node

# StoryLoader
# This script handles loading and managing different story chapters

# References to chapter scripts
var chapter1: Node = null
var chapter_ren: Node = null
var chapter_keiji: Node = null

# Called when the node enters the scene tree for the first time
func _ready():
	# Initialize chapter scripts
	_initialize_chapters()

# Initialize all chapter scripts
func _initialize_chapters():
	# Create Chapter1 instance (Yuki's story)
	chapter1 = load("res://Chapter1.gd").new()
	add_child(chapter1)
	
	# TODO: Create chapters for other characters when they're implemented
	# chapter_ren = load("res://ChapterRen.gd").new()
	# add_child(chapter_ren)
	# 
	# chapter_keiji = load("res://ChapterKeiji.gd").new()
	# add_child(chapter_keiji)

# Start a specific chapter
func start_chapter(chapter_name: String):
	match chapter_name:
		"chapter1":
			if chapter1:
				chapter1.start_chapter()
		"chapter_ren":
			if chapter_ren:
				chapter_ren.start_chapter()
			else:
				# Fallback to simulate a chapter for Ren
				_simulate_character_chapter("ren")
		"chapter_keiji":
			if chapter_keiji:
				chapter_keiji.start_chapter()
			else:
				# Fallback to simulate a chapter for Keiji
				_simulate_character_chapter("keiji")
		_:
			push_error("Unknown chapter: " + chapter_name)

# Simulate a basic chapter for characters without dedicated chapter scripts
func _simulate_character_chapter(character_id: String):
	# Set the current character in StoryManager
	StoryManager.current_character = character_id
	
	# Create a simple message sequence
	StoryManager.clear_queue()
	StoryManager.add_delay(1.0)
	StoryManager.add_message(character_id, "g1", "Hello there! This is a placeholder message for " + character_id.capitalize())
	StoryManager.add_save_progress()
	StoryManager.start_story("simulated_" + character_id)

# Get a reference to a specific chapter
func get_chapter(chapter_name: String) -> Node:
	match chapter_name:
		"chapter1":
			return chapter1
		"chapter_ren":
			return chapter_ren
		"chapter_keiji":
			return chapter_keiji
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

# Simulate receiving a new message for a character
func simulate_new_message(character_id: String, message_content: String = ""):
	var message_id = "simulated_" + str(Time.get_unix_time_from_system())
	
	# If no content provided, generate a placeholder
	if message_content.is_empty():
		message_content = "New message from " + character_id.capitalize() + " at " + Time.get_datetime_string_from_system()
	
	# Use the appropriate chapter to simulate the message
	match character_id:
		"yuki":
			if chapter1:
				return chapter1.simulate_new_message(character_id, message_id)
			else:
				# Fallback if chapter not available
				StoryManager.increment_unread_count(character_id)
				StoryManager.save_progress()
		"ren", "keiji":
			# For characters without dedicated chapters, use StoryManager directly
			StoryManager.increment_unread_count(character_id)
			StoryManager.save_progress()
	
	return message_content