extends Control

var chat_bubble_scene := preload("res://ChatBubble.tscn")

func _ready():
	# connect ke StoryManager signal
	if Engine.is_editor_hint():
		return
	if StoryManager:
		StoryManager.connect("new_chat", Callable(self, "_on_new_chat"))
		# jika mau langsung start story saat main control ready:
		StoryManager.start_story()

func _on_new_chat(character_id: String, chat_item: Dictionary) -> void:
	# chat_item memiliki fields: id, type, content, options?
	var text = chat_item.get("content", "")
	var bubble = chat_bubble_scene.instantiate()
	# bubble default left (is_right = false)
	bubble.set_text(text)
	# untuk NPC (yuki) kita anggap kiri (is_right = false)
	bubble.is_right = false
	$ScrollContainer/MessagesVBox.add_child(bubble)

	# tunggu frame agar layout update lalu auto-scroll ke bawah
	await get_tree().process_frame
	$ScrollContainer.scroll_vertical = $ScrollContainer.get_v_scroll_bar().max_value
