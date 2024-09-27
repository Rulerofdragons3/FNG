extends Button

@export var action:String

func _ready():
	set_process_unhandled_input(false)
	text = InputMap.action_get_events(action)[0].as_text().replace(" (Physical)","")
	
func _on_toggled(buttonPressed):
	set_process_unhandled_input(buttonPressed)
	if buttonPressed:
		text = "<  >"
		release_focus()
	else:
		text = InputMap.action_get_events(action)[0].as_text()
		grab_focus()

func _unhandled_input(event):
	if event.is_pressed():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		print(event)
		ConfigManager.config[action] = event.keycode
		button_pressed = false
