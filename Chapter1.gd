extends Node

# Chapter 1 Story Manager
# This script defines the story flow for Chapter 1

# Reference to the StoryManager singleton
@onready var story_manager = StoryManager

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect to story state changed signal
	if story_manager:
		story_manager.connect("story_state_changed", Callable(self, "_on_story_state_changed"))

# Start the chapter
func start_chapter():
	# Clear any existing story queue
	story_manager.clear_queue()
	
	# Build the story sequence
	_build_intro_sequence()
	
	# Start the story
	story_manager.start_story("chapter1")

# Handle story state changes
func _on_story_state_changed(state_name: String, data: Dictionary):
	print("Story state changed: ", state_name, " with data: ", data)
	
	# Handle different story states
	match state_name:
		"completed":
			print("Chapter 1 completed!")
			# You could trigger the next chapter or show a completion screen

# Build the introduction sequence
func _build_intro_sequence():
	# Example of a complete story sequence for Chapter 1
	
	# Start app - delay for 3 seconds
	story_manager.add_delay(3.0)
	
	# Yuki sends first message (id: g1)
	story_manager.add_message("yuki", "g1")
	
	# Auto-save game
	story_manager.add_save_progress()
	
	# At this point, the story will pause and wait for the player to choose an option
	# The StoryManager will handle the choice and continue based on the next_id in the options
	
	# The story flow will continue in the _process_story_queue method of StoryManager
	# based on the next_id specified in the yuki.json file
	
	# For example, if the player chooses "Not really, what's up?" (option 0),
	# the story will continue with message g2, then g4, etc.
	# If the player chooses "Yeah, I'm working right now." (option 1),
	# the story will continue with message g3 and then end.

# Add a new message and update unread count
func add_new_message_with_notification(character_id: String, message_id: String):
	# Add the message to the story queue
	story_manager.add_message(character_id, message_id)
	
	# Increment the unread count for this character
	story_manager.increment_unread_count(character_id)
	
	# Save progress
	story_manager.add_save_progress()

# Simulate receiving a new message when the app is "closed"
# This can be called from anywhere to simulate a new message notification
func simulate_new_message(character_id: String, message_id: String):
	# Load the message content
	var char_data = story_manager.load_character_json(character_id)
	var message_content = ""
	
	for chat in char_data.get("chat", []):
		if chat.get("id") == message_id:
			message_content = chat.get("content", "")
			break
	
	# Update player progress to record this message
	if not story_manager.player.has("progress"):
		story_manager.player["progress"] = {}
	if not story_manager.player["progress"].has(character_id):
		story_manager.player["progress"][character_id] = {}
	
	story_manager.player["progress"][character_id]["last_seen_id"] = message_id
	
	# Increment unread count
	story_manager.increment_unread_count(character_id)
	
	# Save progress
	story_manager.save_progress()
	
	print("New message from ", character_id, ": ", message_content)
	return message_content