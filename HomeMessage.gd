extends Control

# Dictionary to store contact nodes for easy access
var contact_nodes = {}
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
	
	# Store references to contact nodes
	contact_nodes = {
		"yuki": $ScrollContainer/ContactsVBox/YukiContact,
		"ren": $ScrollContainer/ContactsVBox/RenContact,
		"keiji": $ScrollContainer/ContactsVBox/KeijiContact
	}
	
	# Connect signals for contact selection
	for character_id in contact_nodes:
		contact_nodes[character_id].connect("gui_input", Callable(self, "_on_contact_gui_input").bind(character_id))
	
	# Make panels clickable
	for character_id in contact_nodes:
		contact_nodes[character_id].mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Update unread message badges
	update_unread_badges()

# Handle contact selection
func _on_contact_gui_input(event: InputEvent, character_id: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_contact_pressed(character_id)

# Handle contact press
func _on_contact_pressed(character_id: String):
	print("Contact pressed: ", character_id)
	
	# Set the current character in StoryManager
	StoryManager.current_character = character_id
	
	# Reset unread count for this character
	reset_unread_count(character_id)
	
	# Change to the ActivityMessage scene
	get_tree().change_scene_to_file("res://ActivityMessage.tscn")
	
	# Start the appropriate chapter based on character
	if story_loader:
		var timer = get_tree().create_timer(0.5)
		timer.timeout.connect(func():
			if character_id == "yuki":
				story_loader.start_chapter("chapter1")
			# Add other chapters for other characters as needed
		)

# Update unread message badges for all contacts
func update_unread_badges():
	if StoryManager:
		var player_data = StoryManager.player
		
		# Check for unread messages for each character
		for character_id in contact_nodes:
			var unread_count = get_unread_count(character_id)
			update_badge(character_id, unread_count)

# Get unread message count for a character
func get_unread_count(character_id: String) -> int:
	if StoryManager and StoryManager.player.has("unread_count"):
		return StoryManager.player.get("unread_count", {}).get(character_id, 0)
	return 0

# Update badge for a specific character
func update_badge(character_id: String, count: int):
	if contact_nodes.has(character_id):
		var badge_panel = contact_nodes[character_id].get_node("BadgePanel")
		var count_label = badge_panel.get_node("CountLabel")
		
		if count > 0:
			badge_panel.visible = true
			count_label.text = str(count)
		else:
			badge_panel.visible = false

# Reset unread count for a character
func reset_unread_count(character_id: String):
	if StoryManager:
		if not StoryManager.player.has("unread_count"):
			StoryManager.player["unread_count"] = {}
		
		StoryManager.player["unread_count"][character_id] = 0
		StoryManager.save_progress()
		
		# Update the badge
		update_badge(character_id, 0)