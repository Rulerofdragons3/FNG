extends TextureButton
@export_category("FishVisuals")
@export var fish:Fish
@export var fishName:String
@export var isMirrored:bool = false
@export_category("Properties")
@export var swimRange:Vector2
@export_enum("default","grounded","still") var swimType:String = "default"
@export var forceGoto:Vector2 = Vector2(-1,-1)

var fishSprites:Node
var movements:int = randi_range(2,10)
var aqScript
var isBeingDragged = false
var prevPos = self.position

func create(x:int,y:int):
	self.flip_h = fish.tankIsMirrored	
	self.position = Vector2(x,y)
	isMirrored = fish.tankIsMirrored
	fishName = fish.name
	if forceGoto != Vector2(-1,-1):
		$Timer.stop()
		swim(forceGoto)
	elif randi_range(0,10) == 0:
		var present:Node = load("res://Scenes/Apps/Aquarium/Present.tscn").instantiate()
		$PresentHolder.add_child(present)
	
var swimTween:Tween
func swim(swimTo:Vector2):
	#Mirroring
	if swimTo.x < self.position.x:
		self.flip_h = !isMirrored
	else:
		self.flip_h = isMirrored
	#Movement
	if swimTween:
		swimTween.kill()
	swimTween = create_tween()
	var swimTime = sqrt(
		pow((swimTo.x - self.position.x),2) + 
		pow((swimTo.y - self.position.y),2) 
	) / 100
	swimTween.tween_property(self,"position",swimTo,swimTime)
	#Points the fish in towards it's swimto position
	self.rotation = atan(
		(swimTo.y - self.position.y)
		/
		(swimTo.x - self.position.x)
		)
	
	await swimTween.finished
	return

func stopSwim():
	swimTween.stop()
	swimTween.kill()
	$Timer.stop()

func _on_timer_timeout():
	if isBeingDragged: #Attempt to bugfix
		stopSwim()
		return
	
	$Label.text = str(movements)
	$Timer.stop()
	#Fish kills itself if out of sight
	if movements <= 0:
		dismiss()
		return
	
	await swim(Vector2(
		randf_range(0,swimRange.x),
		randf_range(0,swimRange.y)
	))
	#Timer
	$Timer.wait_time = randi_range(1,5)
	$Timer.start()
	movements -= 1

#Gets rid of fish
func dismiss():
	#Apparently if statements work in var declarations
	var gotoX = -self.size.x if bool(randi_range(0,1)) else (swimRange.x + self.size.x)
	await swim(Vector2(
		gotoX,
		randf_range(0,swimRange.y)
		))
	
	self.queue_free()

########################FISH TEXTUREs########################################
func setTexture(shiny:bool):
	self.texture_normal = fish.texture
	if shiny:
		ShinyHandler.createShiny(self, fish)
		$ShinyParticles.visible = shiny
	
#Sets fish sprite whenever scene tree is entered
func _on_tree_entered():
	var isShiny = false
	if Globals.obtainedFishIDs[fish.resource_path]["caughtShiny"] >= 1:
		isShiny = bool(randi_range(0,1))	
	setTexture(isShiny)
	aqScript = self.find_parent("Aquarium")
	
########################Finteractions####################################

func _on_button_down():
	prevPos = self.position
	$SqueakOut.stop()
	$SqueakIn.play()
	var pressTween = create_tween()
	pressTween.tween_property(self,"scale",Vector2(0.75,0.75),0.1)
	aqScript.dragging = false
	if forceGoto == Vector2(-1,-1):
		stopSwim()
		if movements <= 0:
			movements = 1
		isBeingDragged = true

func _on_button_up():
	var pressTween = create_tween()
	pressTween.tween_property(self,"scale",Vector2(1,1),0.1)
	$Scream.stop()
	if forceGoto == Vector2(-1,-1):
		swim(Vector2(
			randf_range(0,swimRange.x),
			randf_range(0,swimRange.y)
		))
		$Timer.start()
		isBeingDragged = false
	if $SqueakIn.playing:
		await $SqueakIn.finished
	$SqueakOut.play()


func isShaking():
	var v = (self.position.distance_to(prevPos) > 75)
	prevPos = self.position
	return v

func _process(_delta):
	if isBeingDragged:
		self.position = get_global_mouse_position() - (self.size / 2)
		if not $Scream.playing and isShaking():
			$Scream.play()
