extends Control

var chat_bubble_scene := preload("res://ChatBubble.tscn")
var option_buttons := []
var message_manager = null
var back_button = null

signal option_selected(option_index: int)

func _ready():
	# Initialize MessageManager if it doesn't exist
	if not has_node("/root/MessageManager"):
		var message_manager_script = load("res://MessageManager.gd")
		message_manager = message_manager_script.new()
		message_manager.name = "MessageManager"
		get_tree().root.add_child(message_manager)
	else:
		message_manager = get_node("/root/MessageManager")
	
	# Add back button to header
	_add_back_button()
	
	# Connect to StoryManager signals
	if Engine.is_editor_hint():
		return
		
	if StoryManager:
		StoryManager.connect("new_chat", Callable(self, "_on_new_chat"))
		StoryManager.connect("waiting_for_choice", Callable(self, "_on_waiting_for_choice"))
		
		# Setup option buttons
		option_buttons = [$FooterPanel/Option1, $FooterPanel/Option2]
		for i in range(option_buttons.size()):
			option_buttons[i].connect("pressed", Callable(self, "_on_option_pressed").bind(i))
			option_buttons[i].visible = false
		
		# Hide footer panel initially
		$FooterPanel.visible = false
		
		# Update header with character name
		_update_header_with_character()
		
		# Start the story automatically after a short delay
		get_tree().create_timer(0.5).timeout.connect(func():
			start_story()
		)

# Add back button to header
func _add_back_button():
	back_button = Button.new()
	back_button.text = "< Back"
	back_button.position = Vector2(20, 20)
	back_button.size = Vector2(150, 60)
	back_button.connect("pressed", Callable(self, "_on_back_button_pressed"))
	$HeaderPanel.add_child(back_button)

# Update header with current character name
func _update_header_with_character():
	if StoryManager and StoryManager.current_character != "":
		var character_name = StoryManager.current_character.capitalize()
		var char_data = StoryManager.load_character_json(StoryManager.current_character)
		if char_data.has("name"):
			character_name = char_data.get("name")
		
		$HeaderPanel/Label.text = character_name

# Handle back button press
func _on_back_button_pressed():
	# Go back to HomeMessage scene
	get_tree().change_scene_to_file("res://HomeMessage.tscn")

# Start the story sequence
func start_story():
	if StoryManager:
		# If there's an active story, don't restart it
		if not StoryManager.is_story_running:
			# Load previous messages for this character
			_load_previous_messages()
			
			# Only start a new story if we're not already in one
			if StoryManager.current_state == "idle":
				StoryManager.start_story()

# Load previous messages for the current character
func _load_previous_messages():
	if StoryManager and StoryManager.current_character != "":
		var character_id = StoryManager.current_character
		var char_data = StoryManager.load_character_json(character_id)
		var last_seen_id = StoryManager.player.get("progress", {}).get(character_id, {}).get("last_seen_id", "")
		
		if last_seen_id != "":
			var messages_to_show = []
			var found_last = false
			
			# Collect all messages up to the last seen
			for chat in char_data.get("chat", []):
				messages_to_show.append(chat)
				if chat.get("id") == last_seen_id:
					found_last = true
					break
			
			# Display the messages
			if found_last:
				for chat in messages_to_show:
					var bubble = message_manager.add_message_to_container($ScrollContainer/MessagesVBox, character_id, chat.get("content", ""))
				
				# If the last message had options and a choice was made, show the player's response
				var last_chat_id = last_seen_id
				var player_choice = StoryManager.get_player_choice(last_chat_id)
				
				if player_choice >= 0:
					for chat in char_data.get("chat", []):
						if chat.get("id") == last_chat_id and chat.has("options"):
							var options = chat.get("options", [])
							if player_choice < options.size():
								var player_text = options[player_choice].get("text", "")
								var player_bubble = message_manager.add_message_to_container($ScrollContainer/MessagesVBox, "player", player_text)
				
				# Auto-scroll to the bottom
				await get_tree().process_frame
				$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value

# Handle new chat message from StoryManager
func _on_new_chat(character_id: String, chat_item: Dictionary) -> void:
	# Hide options when receiving new chat
	_hide_options()
	
	# Handle different message types
	match chat_item.get("type", "text"):
		"text":
			_display_text_message(character_id, chat_item)
		"prompt":
			_display_text_message(character_id, chat_item)
			_show_options(chat_item.get("options", []))

# Display a text message in the chat
func _display_text_message(character_id: String, chat_item: Dictionary) -> void:
	var text = chat_item.get("content", "")
	
	# Use MessageManager to create and add the bubble
	var bubble = message_manager.add_message_to_container($ScrollContainer/MessagesVBox, character_id, text)
	
	# Auto-scroll to the bottom
	await get_tree().process_frame
	$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value

# Handle waiting for player choice
func _on_waiting_for_choice(character_id: String, options: Array) -> void:
	_show_options(options)

# Show options for player to choose from
func _show_options(options: Array) -> void:
	$FooterPanel.visible = true
	
	# Hide all option buttons first
	for button in option_buttons:
		button.visible = false
	
	# Show and configure available options
	for i in range(min(options.size(), option_buttons.size())):
		option_buttons[i].visible = true
		option_buttons[i].text = options[i].get("text", "Option " + str(i+1))

# Hide all option buttons
func _hide_options() -> void:
	$FooterPanel.visible = false
	for button in option_buttons:
		button.visible = false

# Handle option button press
func _on_option_pressed(option_index: int) -> void:
	# Hide options after selection
	_hide_options()
	
	# Add player's response as a chat bubble
	var options = []
	if StoryManager.is_waiting_for_choice:
		var current_char = StoryManager.current_character
		var char_data = StoryManager.load_character_json(current_char)
		for chat in char_data.get("chat", []):
			if chat.get("id") == StoryManager.current_chat_id:
				options = chat.get("options", [])
				break
	
	if options.size() > option_index:
		var player_text = options[option_index].get("text", "")
		var player_bubble = message_manager.add_message_to_container($ScrollContainer/MessagesVBox, "player", player_text)
		
		# Auto-scroll to the bottom
		await get_tree().process_frame
		$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value
	
	# Notify StoryManager about the choice
	StoryManager.handle_choice(option_index)

# Clear all messages
func clear_messages() -> void:
	for child in $ScrollContainer/MessagesVBox.get_children():
		child.queue_free()