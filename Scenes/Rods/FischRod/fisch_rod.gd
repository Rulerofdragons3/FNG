extends Rod

var active = false
const MAXACCELERATION = 0.02
var ACCELAMOUNT = 0.01
const ACTIVETIME = 10.1 #Progress rate
const INITIALPROGRESS = 5
var progress:float = 0
var acceleration:float

func _ready() -> void:
	self.visible = false

func startMinigame() -> void:
	self.visible = true
	await self.get_tree().create_timer(1).timeout
	$ReelingIn.play()
	$MoveTimer.start()
	active = true

func endMinigame() -> void:
	active = false
	$MoveTimer.stop()
	$ReelingIn.stop()
	await self.get_tree().create_timer(1).timeout
	$ReelingOut.play()
	$Reel/Handle.rotation_degrees = int($Reel/Handle.rotation_degrees) % 360
	var tween = create_tween()
	tween.tween_property($Reel/Handle,"rotation_degrees",720,1)
	await tween.finished
	$ReelingOut.stop()
	self.visible = false
	progress = INITIALPROGRESS
	acceleration = 0
	$Rod/ReelMarker.anchor_left = 0.5
	$Rod/ReelMarker.anchor_right = 0.5
	$Rod/FishMarker.anchor_left = 0.5
	$Rod/FishMarker.anchor_right = 0.5

func success() -> void:
	$MoveTimer.stop()
	$FishCaught.play()
	await endMinigame()
	self.catchFish(randi_range(1,5))
	$Splash.play()
	
func fail() -> void:
	await endMinigame()
	$TinySplash.play()

func _unhandled_input(event: InputEvent) -> void:
	if not self.canFish:
		return
	if not active:
		if event.is_action_pressed("StartMinigame") and not self.visible:
			startMinigame()
		return

func moveBar():
	$Rod/ReelMarker.anchor_left = clamp($Rod/ReelMarker.anchor_left + acceleration,0.13,0.85)
	$Rod/ReelMarker.anchor_right = clamp($Rod/ReelMarker.anchor_right + acceleration,0.13,0.85)
	# End behavior
	if $Rod/ReelMarker.anchor_left <= 0.131 or $Rod/ReelMarker.anchor_left >= 0.85:
		acceleration = 0

func fishInBar():
	var fishx = $Rod/FishMarker.position.x
	var barx = $Rod/ReelMarker.position.x
	var offsetR = $Rod/ReelMarker.offset_right + 1
	var LPos = barx
	var RPos = barx + (offsetR * 2)
	return (fishx >= LPos) and (fishx <= RPos)
	
func doprogress(delta):
	var progressAmount = (ACTIVETIME) * delta
	if fishInBar():
		progress += progressAmount
	else:
		progress -= progressAmount
	$ProgressBar/Progress.scale = Vector2(progress/100,1)
	#Check progress
	if progress >= 100:
		success()
	elif progress <= 0:
		fail()

func _process(_delta: float) -> void:
	if not active:
		return
	var fps = Engine.get_frames_per_second()
	var accelAmount = (ACCELAMOUNT / fps)
	var push:bool = Input.is_action_pressed("StartMinigame") or Input.is_action_pressed("Click")
	if push:
		acceleration = clamp(acceleration + accelAmount, -MAXACCELERATION, MAXACCELERATION)
	else:
		acceleration = clamp(acceleration - accelAmount, -MAXACCELERATION, MAXACCELERATION)
	$Reel/Handle.rotation += 0.2 + acceleration * 10
	$ReelingIn.pitch_scale = clamp(1 + (acceleration * 10),0.8,1.2)
	moveBar()
	doprogress(_delta)
	
func _on_move_timer_timeout() -> void:
	$MoveTimer.stop()
	if not active:
		return
	var tweenTo = clamp(
		$Rod/FishMarker.anchor_left + randf_range(-0.25,0.25),
		0,1
		)
	var tween = create_tween()
	tween.tween_property($Rod/FishMarker,"anchor_left", tweenTo, 1)
	tween.parallel().tween_property($Rod/FishMarker,"anchor_right", tweenTo, 1)
	tween.play()
	await tween.finished
	$MoveTimer.start(randf_range(0.3,1.0))
