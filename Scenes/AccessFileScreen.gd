extends ColorRect

signal changeWallpaper(path)

func _ready():
	$FileDialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES)

func _on_file_dialog_file_selected(path):
	self.hide()
	print(path)
	changeWallpaper.emit(path)
	

func _on_visibility_changed():
	if self.visible:
		$FileDialog.show()

func _on_file_dialog_visibility_changed():
	if !$FileDialog.visible:
		self.hide()
