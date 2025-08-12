extends Node

# MessageManager
# This script provides universal methods for message handling

# Signal for when a new message is created
signal message_created(message_node: Node)

# Reference to the chat bubble scene
var chat_bubble_scene := preload("res://ChatBubble.tscn")

# Character color mapping
var character_colors := {
	"player": Color(0.2, 0.6, 0.3, 1.0),
	"yuki": Color(0.12, 0.51, 0.96, 1.0),
	"ren": Color(0.9, 0.3, 0.3, 1.0),
	"keiji": Color(0.5, 0.5, 0.5, 1.0)
}

# Create a new message bubble
func create_message_bubble(character_id: String, text: String) -> Node:
	var bubble = chat_bubble_scene.instantiate()
	
	# Set bubble properties based on character
	bubble.is_right = (character_id == "player")
	
	# Set custom styling based on character
	if character_colors.has(character_id):
		bubble.set_bubble_color(character_colors[character_id])
	
	bubble.set_text(text)
	
	# Emit signal that a new message was created
	emit_signal("message_created", bubble)
	
	return bubble

# Add a message to a container
func add_message_to_container(container: Node, character_id: String, text: String) -> Node:
	var bubble = create_message_bubble(character_id, text)
	container.add_child(bubble)
	return bubble

# Create a player response message
func create_player_response(text: String) -> Node:
	return create_message_bubble("player", text)

# Create an NPC message
func create_npc_message(character_id: String, text: String) -> Node:
	return create_message_bubble(character_id, text)

# Set custom color for a character
func set_character_color(character_id: String, color: Color):
	character_colors[character_id] = color

# Get character color
func get_character_color(character_id: String) -> Color:
	if character_colors.has(character_id):
		return character_colors[character_id]
	return Color(0.5, 0.5, 0.5, 1.0)  # Default gray