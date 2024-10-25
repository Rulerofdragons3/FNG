extends Control

func _ready() -> void:
	#self.scale = Vector2(DisplayServer.window_get_size()) / $Background.size
	#print(DisplayServer.window_get_size())
	#print(self.scale)
	pass
	
func _on_texture_button_pressed() -> void:
	get_tree().quit()
