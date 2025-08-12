extends Control

var message_manager = null
var option_buttons := []

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

# Start the story sequence
func start_story():
	if StoryManager:
		StoryManager.start_story()

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
		
		# Use MessageManager to create and add the player response
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