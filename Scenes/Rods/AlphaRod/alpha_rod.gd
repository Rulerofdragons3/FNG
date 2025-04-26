extends Rod

var active = false
var defaultWaitTime:float
var wordChoices:PackedStringArray
var wordToType:String
var currentChar:int = 0
var wordLength:int

func _ready() -> void:
	var file:String = FileAccess.get_file_as_string("res://Scenes/Rods/AlphaRod/Jargon.txt")
	wordChoices = file.split("\n")
	self.visible = false
	defaultWaitTime = $CatchTimer.wait_time

func startMinigame() -> void:
	active = true
	#setUIEnabled(false)
	wordToType = wordChoices[
		randi_range(0,len(wordChoices) - 3) #Sub 2 due to last entry in wordChoices being ""
		]
	currentChar = 0
	wordLength = len(wordToType)
	$ToType.text = wordToType
	setTypedText()
	$CatchTimer.wait_time = defaultWaitTime
	$ReelingIn.play()
	self.visible = true
	$CatchTimer.start()
	

func endMinigame() -> void:
	active = false
	$ReelingIn.stop()
	await self.get_tree().create_timer(1).timeout
	$ReelingOut.play()
	$Reel/Handle.rotation_degrees = int($Reel/Handle.rotation_degrees) % 360
	var tween = create_tween()
	tween.tween_property($Reel/Handle,"rotation_degrees",720,1)
	await tween.finished
	$ReelingOut.stop()
	self.visible = false
	#self.setUIEnabled(true)

func success() -> void:
	$CatchTimer.stop()
	$FishCaught.play()
	await endMinigame()
	self.catchFish(wordLength)
	$Splash.play()
	
func fail() -> void:
	await endMinigame()
	$TinySplash.play()

func setTypedText():
	$TypedWords.text = wordToType.substr(0, currentChar)
	$TypedWords.text += ("[pulse freq=5]" + wordToType[currentChar] + "[/pulse]") if (
		currentChar != wordLength) else ""
	$ComboCatch.pitch_scale = randf_range(0.6,1.6)
	$ComboCatch.play()

func checkChar(event:InputEvent) -> bool:
	var character = wordToType[currentChar]
	var key = event.as_text()
	#print(event.as_text())
	if character == " " and key == "Space":
		return true
	return (character.to_upper() == key)

func _unhandled_input(event: InputEvent) -> void:
	if not self.canFish:
		return
	if not active:
		if event.is_action_pressed("StartMinigame") and not self.visible:
			startMinigame()
		return
	if (event is InputEventMouse) or (event.is_released()):
		return
	
	#Yay you typed the right thing!!!
	if checkChar(event):
		currentChar += 1
		$CatchTimer.start(1)
		setTypedText()
		if currentChar == wordLength:
			success()
			return
	#Bumemr...
	else:
		fail()

func _process(delta: float) -> void:
	if not active:
		return
	$Rod/TimerBar.scale = Vector2($CatchTimer.time_left / $CatchTimer.wait_time,1)
	$Reel/Handle.rotation_degrees -= 2000 * delta

func _on_catch_timer_timeout() -> void:
	if active:
		fail()
		$CatchTimer.stop()
