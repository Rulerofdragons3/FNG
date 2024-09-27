extends Control

#Objects
var fishScene = preload("res://Scenes/tankfish.tscn")
var convScene = preload("res://Scenes/conversation.tscn")
@onready var phoneMenu = $"../Ui/Phone"
#Drag Controls
@export var dragging:bool = false
var camLocation : Vector2
var mouseLocation : Vector2
@onready var tankDimensions:Vector2 = $SubViewportContainer/SubViewport.size
# Called when the node enters the scene tree for the first time.
func _ready():
	$SubViewportContainer/SubViewport/AQCamera.position = $SubViewportContainer/SubViewport/BG.size / 2

func _process(_delta):
	if !self.visible:
		return
	#We game
	if dragging:
		var dragPos = mouseLocation - get_local_mouse_position()
		var camBounds:Vector2 = $SubViewportContainer/SubViewport.size / 2
		var newPos = Vector2(
			clamp(camLocation.x + dragPos.x,
				camBounds.x,
				$SubViewportContainer/SubViewport/BG.size.x - camBounds.x),
			clamp(camLocation.y + dragPos.y,
				camBounds.y,
				$SubViewportContainer/SubViewport/BG.size.y - camBounds.y)
			) #Ugly but functional so whatever
		$SubViewportContainer/SubViewport/AQCamera.position = newPos 

#Controls drag
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouseLocation = get_local_mouse_position()
			camLocation = $SubViewportContainer/SubViewport/AQCamera.position
			dragging = true
		elif event.button_index == 1 and not event.is_pressed():
			dragging = false


func instantiateFish():
	if len(Globals.obtainedFishIDs) <= 0:
		return
	
	var tankfish = fishScene.instantiate()
	var ID = Globals.obtainedFishIDs.pick_random()
	tankfish.fishID = ID
	tankfish.swimRange = $SubViewportContainer/SubViewport/BG.size - Vector2(0,100)
	if "tankIsMirrored" in Globals.fishData[ID]:
		tankfish.isMirrored = Globals.fishData[ID]["tankIsMirrored"]
	
	tankfish.create(
		randi_range(0,1) * $SubViewportContainer/SubViewport/BG.size.x,
		randi_range(0,$SubViewportContainer/SubViewport/BG.size.y)
	)
	$SubViewportContainer/SubViewport/FishContainer.add_child(tankfish)

func _on_fish_spawn_timer_timeout():
	if $SubViewportContainer/SubViewport/FishContainer.get_child_count() < 20:
		instantiateFish()


func _on_conversation_timer_timeout():
	if $SubViewportContainer/SubViewport/FishConvoContainer.get_child_count() < 1:
		var convo = convScene.instantiate()
		convo.position = Vector2(
			randi_range(300,$SubViewportContainer/SubViewport/BG.size.x - 300),
			randi_range(500,$SubViewportContainer/SubViewport/BG.size.y - 200)
		)
		$SubViewportContainer/SubViewport/FishConvoContainer.add_child(convo)


func _on_exit_button_pressed():
	self.hide()
	phoneMenu.show()
