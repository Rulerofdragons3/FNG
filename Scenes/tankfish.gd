extends TextureButton
@export_category("FishVisuals")
@export var fishID:int
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

func create(x:int,y:int):
	self.flip_h = isMirrored	
	self.position = Vector2(x,y)
	fishName = Globals.fishData[fishID]["name"]
	if forceGoto != Vector2(-1,-1):
		$Timer.stop()
		swim(forceGoto)
		
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
	await swim(Vector2(
		float(randi_range(0,1)) * swimRange.x,
		randf_range(0,swimRange.y)
		))
	self.queue_free()

########################FISH TEXTUREs########################################
func getTexture(ID, isShiny = false):
	var frameData
	if !fishSprites: #Prevents errors
		return null
	frameData = fishSprites.sprite_frames.get_frame_texture("default",ID)
	if isShiny:
		if "shinyOverride" in Globals.fishData[ID]:
			if Globals.fishData[ID]["shinyOverride"] == "none":
				return frameData
			return ShinyHandler.createShiny(
				frameData.get_image(),
				Globals.fishData[ID]["shinyOverride"])
		else:
			return ShinyHandler.createShiny(frameData.get_image())
	return frameData


#Sets fish sprite whenever scene tree is entered
func _on_tree_entered():
	fishSprites = get_tree().root.get_node("Scene").get_node("FishSprites")
	var isShiny = false
	if fishID in Globals.obtainedShinies:
		isShiny = bool(randi_range(0,1))
		
	self.texture_normal = getTexture(fishID, isShiny)
	aqScript = self.get_parent().get_parent().get_parent().get_parent()
########################Finteractions####################################

func _on_button_down():
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
	
func _process(_delta):
	if isBeingDragged:
		self.global_position = get_global_mouse_position() - Vector2(
			self.size.x / 2,
			self.size.y / 2
		)
