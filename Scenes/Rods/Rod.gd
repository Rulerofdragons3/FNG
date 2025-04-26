extends Control
class_name Rod

var canFish:bool = true

func catchFish(luckMult:float,bigCatch:bool = true):
	var CS:Node = $"../../CatchScreen"
	assert(CS, "Could not find catchscreen")
	CS.on_fish_caught(luckMult, bigCatch)

func setUIEnabled(enabled:bool):
	var menuButton = $"../../Ui/MenuButton"
	menuButton.disabled = not enabled
