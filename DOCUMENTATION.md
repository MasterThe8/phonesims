# PhoneSims Story System Documentation

This document explains how to use the new modular story system for PhoneSims.

## Overview

The story system consists of several components:

1. **StoryManager** - Core singleton that manages the story flow, player choices, and save/load functionality
2. **MessageManager** - Handles message creation and styling
3. **StoryLoader** - Manages different story chapters
4. **Chapter Scripts** - Individual scripts for each chapter that define the story flow

## How to Create a Story

### 1. Create Character JSON Files

Character JSON files should be placed in `assets/chapter1/` (or other chapter folders) and follow this format:

```json
{
  "id": "character_id",
  "name": "Character Name",
  "chat": [
    {
      "id": "message_id",
      "type": "text",
      "content": "Message content",
      "options": [
        {
          "text": "Option 1 text",
          "next_id": "next_message_id"
        },
        {
          "text": "Option 2 text",
          "next_id": "alternative_message_id"
        }
      ]
    },
    {
      "id": "next_message_id",
      "type": "text",
      "content": "Next message content",
      "next_id": "another_message_id"
    }
  ]
}
```

### 2. Create a Chapter Script

Create a new script that extends `Node` and defines the story flow:

```gdscript
extends Node

@onready var story_manager = StoryManager

func _ready():
	if story_manager:
		story_manager.connect("story_state_changed", Callable(self, "_on_story_state_changed"))

func start_chapter():
	story_manager.clear_queue()
	_build_story_sequence()
	story_manager.start_story("chapter_name")

func _build_story_sequence():
	# Start app
	story_manager.add_delay(3.0)  # Wait 3 seconds
	
	# NPC sends message
	story_manager.add_message("character_id", "message_id")
	
	# Auto-save game
	story_manager.add_save_progress()
	
	# The story will pause here and wait for player choice
	# After player chooses, it will continue based on the next_id in the options
```

### 3. Register the Chapter in StoryLoader

Add your chapter to the StoryLoader:

```gdscript
# In StoryLoader.gd

var chapter_name: Node = null

func _initialize_chapters():
	# Create Chapter instance
	chapter_name = load("res://ChapterName.gd").new()
	add_child(chapter_name)

func start_chapter(chapter_name: String):
	match chapter_name:
		"chapter_name":
			if chapter_name:
				chapter_name.start_chapter()
```

### 4. Start the Chapter

To start the chapter from another script:

```gdscript
var story_loader = get_node("/root/StoryLoader")
if story_loader:
	story_loader.start_chapter("chapter_name")
```

## Story Flow Control

### Adding Story Elements

The StoryManager provides several methods to add elements to the story queue:

- `add_delay(seconds)` - Add a delay
- `add_message(character_id, message_id)` - Add a message
- `add_save_progress()` - Save the game
- `add_custom_action(callable)` - Execute a custom function
- `add_choices(character_id, prompt, options)` - Add choices for the player

### Branching

You can create branching paths using custom actions:

```gdscript
func _branch_based_on_choice():
	var choice = story_manager.get_player_choice("message_id")
	
	if choice == 0:  # First option
		story_manager.add_message("character_id", "path_a_message")
	else:  # Second option
		story_manager.add_message("character_id", "path_b_message")
```

### Custom Actions

You can add custom actions to the story queue:

```gdscript
story_manager.add_custom_action(Callable(self, "_my_custom_action"))

func _my_custom_action():
	print("Custom action executed")
	# Do something custom here
```

## Message Styling

The MessageManager handles message styling:

```gdscript
# Set character colors
MessageManager.set_character_color("character_id", Color(r, g, b))

# Create a message bubble
var bubble = MessageManager.create_message_bubble("character_id", "Message text")

# Add a message to a container
MessageManager.add_message_to_container(container_node, "character_id", "Message text")
```

## Example Story Flow

Here's an example of a complete story flow:

1. App starts
2. Wait 3 seconds
3. Yuki sends message "Hey babe, are you busy?"
4. Player chooses "Not really, what's up?"
5. Yuki sends message "I want to tell you something... but promise you won't get mad?"
6. Yuki sends message "I had lunch with a male coworker earlier."
7. Player chooses "Who? Why didn't you tell me?"
8. Yuki sends message "He's just a friend, I swear."
9. End of chapter

## Tips for Creating Stories

1. **Plan your story flow** - Sketch out the conversation flow before coding
2. **Use meaningful IDs** - Use descriptive IDs for messages (e.g., "intro_1", "yuki_jealous_1")
3. **Save frequently** - Add save points after important choices
4. **Test all branches** - Make sure all story branches work correctly
5. **Use custom actions** - For complex logic or special events
6. **Keep character files organized** - Split long conversations into multiple files if needed

## Advanced Features

### Checking Previous Choices

```gdscript
var previous_choice = story_manager.get_player_choice("message_id")
```

### Checking if Player Has Seen a Message

```gdscript
var has_seen = story_manager.has_seen_chat("character_id", "message_id")
```

### Creating Multi-Character Conversations

```gdscript
func create_conversation():
	story_manager.add_message("yuki", "y1")
	story_manager.add_delay(1.0)
	story_manager.add_message("ren", "r1")
	story_manager.add_delay(1.0)
	story_manager.add_message("keiji", "k1")
```