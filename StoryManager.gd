extends Node


signal new_chat(character_id: String, chat_item: Dictionary)
signal waiting_for_choice(character_id: String, options: Array)
signal story_state_changed(state_name: String, data: Dictionary)


File paths

var autosave_path := "user://assets/savegame/autosave.json"
var chapter_folder := "res://assets/chapter1/"


Player data

var player := {}
var current_state := "idle"
var current_character := ""
var current_chat_id := ""
var is_waiting_for_choice := false


Story flow control

var story_queue := []
var is_story_running := false


func _ready():
	load_autosave()


-------------------------

Story Flow Control Methods

-------------------------

Start a story sequence

func start_story(sequence_name: String = "default"):
	load_autosave()
	is_story_running = true
	current_state = "running"
	emit_signal("story_state_changed", "started", {"sequence": sequence_name})
	
	# If we have a specific sequence to run, we could load it here
	# For now, we'll just process the queue if it exists
	_process_story_queue()


Add a delay to the story queue

func add_delay(seconds: float) -> StoryManager:
	story_queue.append({
		"type": "delay",
		"duration": seconds
	})
	return self


Add a message to the story queue

func add_message(character_id: String, message_id: String, content: String = "") -> StoryManager:
	var message_data = {
		"id": message_id,
		"type": "text",
		"content": content
	}
	
	# If content is empty, try to load from character file
	if content.is_empty():
		var char_data = load_character_json(character_id)
		for chat in char_data.get("chat", []):
			if chat.get("id") == message_id:
				message_data = chat
				break
	
	story_queue.append({
		"type": "message",
		"character_id": character_id,
		"message": message_data
	})
	return self


Add choices for the player to select from

func add_choices(character_id: String, prompt: String, options: Array) -> StoryManager:
	story_queue.append({
		"type": "choices",
		"character_id": character_id,
		"prompt": prompt,
		"options": options
	})
	return self


Save current progress

func add_save_progress() -> StoryManager:
	story_queue.append({
		"type": "save"
	})
	return self


Execute a custom function

func add_custom_action(callable: Callable) -> StoryManager:
	story_queue.append({
		"type": "custom",
		"callable": callable
	})
	return self


Process the next item in the story queue

func _process_story_queue():
	if story_queue.is_empty():
		is_story_running = false
		current_state = "idle"
		emit_signal("story_state_changed", "completed", {})
		return
	
	var item = story_queue.pop_front()
	
	match item.get("type"):
		"delay":
			await get_tree().create_timer(item.get("duration", 1.0)).timeout
			_process_story_queue()
		
		"message":
			current_character = item.get("character_id", "")
			current_chat_id = item.get("message", {}).get("id", "")
			
			# Update player progress
			if not player.has("progress"):
				player["progress"] = {}
			if not player["progress"].has(current_character):
				player["progress"][current_character] = {}
			
			player["progress"][current_character]["last_seen_id"] = current_chat_id
			
			# Emit the message
			emit_signal("new_chat", current_character, item.get("message", {}))
			
			# Continue to next item if this message doesn't require waiting
			if not item.get("message", {}).has("options"):
				_process_story_queue()
		
		"choices":
			current_character = item.get("character_id", "")
			is_waiting_for_choice = true
			
			# Create a message with the prompt
			var prompt_message = {
				"id": "choice_prompt",
				"type": "prompt",
				"content": item.get("prompt", ""),
				"options": item.get("options", [])
			}
			
			emit_signal("new_chat", current_character, prompt_message)
			emit_signal("waiting_for_choice", current_character, item.get("options", []))
			
			# Story processing will pause here until handle_choice is called
		
		"save":
			save_progress()
			_process_story_queue()
		
		"custom":
			if item.has("callable") and item.get("callable") is Callable:
				await item.get("callable").call()
			_process_story_queue()


Handle player's choice selection

func handle_choice(option_index: int):
	if not is_waiting_for_choice:
		push_error("Received choice but not waiting for one")
		return
	
	is_waiting_for_choice = false
	
	# Here you can add logic to branch the story based on the choice
	# For now, we'll just continue the story
	
	# Record the choice in player data
	if not player.has("choices"):
		player["choices"] = {}
	
	player["choices"][current_chat_id] = option_index
	
	# Continue processing the story queue
	_process_story_queue()


-------------------------

Save/Load Methods

-------------------------

Save current progress

func save_progress():
	var dir = DirAccess.open("user://assets/savegame/")
	if not dir:
		# Create directories if they don't exist
		DirAccess.make_dir_recursive_absolute("user://assets/savegame/")
	
	var save_data = {
		"player": player,
		"timestamp": Time.get_unix_time_from_system(),
		"version": "1.0"
	}
	
	var file = FileAccess.open(autosave_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "  "))
		file.close()
	else:
		push_error("Failed to save progress: " + str(FileAccess.get_open_error()))


Load saved progress

func load_autosave():
	var file : FileAccess = null
	if FileAccess.file_exists(autosave_path):
		file = FileAccess.open(autosave_path, FileAccess.READ)
	else:
		var fallback = "res://assets/savegame/autosave.json"
		if FileAccess.file_exists(fallback):
			file = FileAccess.open(fallback, FileAccess.READ)


if file:
	var txt = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(txt)
	if parsed is Dictionary:
		player = parsed.get("player", {})
	else:
		push_error("Failed to parse autosave JSON")
else:
	player = {}

-------------------------

Character Data Methods

-------------------------

Load character data from JSON file

func load_character_json(char_id: String) -> Dictionary:
	var path = "%s%s.json" % [chapter_folder, char_id]
	if not FileAccess.file_exists(path):
		push_error("Character file not found: %s" % path)
		return {}


var f = FileAccess.open(path, FileAccess.READ)
var txt = f.get_as_text()
f.close()

var parsed = JSON.parse_string(txt)
if parsed is Dictionary:
	return parsed
else:
	push_error("JSON parse error in file: %s" % path)
	return {}

Get a specific chat item from a character

func get_chat_item(character_id: String, chat_id: String) -> Dictionary:
	var char_data = load_character_json(character_id)
	for chat in char_data.get("chat", []):
		if chat.get("id") == chat_id:
			return chat
	return {}


-------------------------

Utility Methods

-------------------------

Clear the story queue

func clear_queue():
	story_queue.clear()
	is_story_running = false
	current_state = "idle"


Check if a specific chat has been seen

func has_seen_chat(character_id: String, chat_id: String) -> bool:
	var last_seen = player.get("progress", {}).get(character_id, {}).get("last_seen_id", "")
	var char_data = load_character_json(character_id)
	
	var found_target = false
	var found_last_seen = last_seen.is_empty()
	
	for chat in char_data.get("chat", []):
		if chat.get("id") == chat_id:
			found_target = true
		if chat.get("id") == last_seen:
			found_last_seen = true
			
		if found_target and not found_last_seen:
			return false
	
	return found_target and found_last_seen


Get player choice for a specific chat

func get_player_choice(chat_id: String) -> int:
	return player.get("choices", {}).get(chat_id, -1)
