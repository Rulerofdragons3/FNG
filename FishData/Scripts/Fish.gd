@tool
extends Resource
class_name Fish


@export_category("Appearance")
@export var texture:Texture
@export var name:String = ""
@export_multiline var description:String = ""
enum ShinyOverrides {Invert,TrueInvert,Hue,Modulate,Custom,None}

@export_category("Values")
@export var value:float = 0
@export var rarity:int = 0
@export var worlds:Array[String] = ["ocean"]
@export var tankIsMirrored:bool = false
@export_category("Shiny Overrides")
@export_multiline var shinyDescription = ""
@export var shinyOverride:ShinyOverrides:
	set(val):
		shinyOverride = val
		notify_property_list_changed()

var shinyValue = null

func _get_property_list():
	var properties = []
	match shinyOverride:
		ShinyOverrides.Modulate:
			properties.append({
				"name": "Custom_Modulate",
				"type": TYPE_COLOR,
				"hint": PROPERTY_HINT_COLOR_NO_ALPHA,
				"hint_string": ""
			})
		ShinyOverrides.Hue:
			properties.append({
				"name": "Custom_Hue",
				"type": TYPE_INT
			})
		ShinyOverrides.Custom:
			properties.append({
				"name": "Custom_Texture",
				"type": TYPE_OBJECT,
				"hint": PROPERTY_HINT_RESOURCE_TYPE,
				"hint_string": "Texture"
			})
		_:
			shinyValue = null
	return properties

func _get(property):
	if property.begins_with("Custom_"):
		return shinyValue
	
func _set(property, val):
	if property.begins_with("Custom_"):
		shinyValue = val
		return true
	return false
