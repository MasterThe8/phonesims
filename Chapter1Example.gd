extends Node

# Chapter 1 Example - Full Story Flow
# This script demonstrates how to create a complete story flow for Chapter 1

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
	_build_story_sequence()
	
	# Start the story
	story_manager.start_story("chapter1_example")

# Handle story state changes
func _on_story_state_changed(state_name: String, data: Dictionary):
	print("Story state changed: ", state_name, " with data: ", data)
	
	# Handle different story states
	match state_name:
		"completed":
			print("Chapter 1 Example completed!")

# Build the complete story sequence
func _build_story_sequence():
	# This is an example of how to build a complete story sequence
	# with branching paths and multiple characters
	
	# --- Start App ---
	# Wait 3 seconds after app starts
	story_manager.add_delay(3.0)
	
	# --- First Message ---
	# Yuki sends first message (id: g1)
	story_manager.add_message("yuki", "g1")
	
	# Auto-save game
	story_manager.add_save_progress()
	
	# At this point, the story will pause and wait for the player to choose an option
	# The StoryManager will handle the choice and continue based on the next_id in the options
	
	# --- Custom Action Example ---
	# Add a custom action to the story queue
	story_manager.add_custom_action(Callable(self, "_custom_action_example"))
	
	# --- Conditional Branch Example ---
	# Add a custom action that will check the player's choice and branch accordingly
	story_manager.add_custom_action(Callable(self, "_branch_based_on_g1_choice"))
	
	# --- End of Chapter ---
	# Add a delay before ending
	story_manager.add_delay(2.0)
	
	# Add a final message
	story_manager.add_message("yuki", "g5")
	
	# Save progress
	story_manager.add_save_progress()

# Custom action example
func _custom_action_example():
	print("Executing custom action in Chapter 1 Example")
	# You can perform any custom logic here
	# For example, changing game state, updating UI, etc.

# Branch based on player's choice for g1
func _branch_based_on_g1_choice():
	# Get the player's choice for g1
	var g1_choice = story_manager.get_player_choice("g1")
	
	if g1_choice == 0:  # Player chose "Not really, what's up?"
		# Continue with g2 -> g4 path
		story_manager.add_message("yuki", "g2")
		story_manager.add_delay(1.5)
		story_manager.add_message("yuki", "g4")
	else:  # Player chose "Yeah, I'm working right now."
		# End the conversation
		story_manager.add_message("yuki", "g3")
	
	# Save progress
	story_manager.add_save_progress()

# --- Additional Helper Methods ---

# Example of how to create a complete conversation sequence
func create_conversation_sequence(character_id: String, message_ids: Array, delay_between: float = 1.0):
	for message_id in message_ids:
		story_manager.add_message(character_id, message_id)
		if message_id != message_ids[-1]:  # Don't add delay after the last message
			story_manager.add_delay(delay_between)
	
	# Save progress after the conversation
	story_manager.add_save_progress()

# Example of how to create a multi-character conversation
func create_multi_character_conversation(conversation_data: Array):
	# conversation_data is an array of dictionaries with character_id and message_id
	# Example: [{"character": "yuki", "message": "g1"}, {"character": "ren", "message": "r1"}]
	
	for item in conversation_data:
		var character_id = item.get("character", "")
		var message_id = item.get("message", "")
		var delay = item.get("delay", 1.0)
		
		if not character_id.is_empty() and not message_id.is_empty():
			story_manager.add_message(character_id, message_id)
			story_manager.add_delay(delay)
	
	# Save progress after the conversation
	story_manager.add_save_progress()