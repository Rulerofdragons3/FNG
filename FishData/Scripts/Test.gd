@tool
extends Resource
class_name Test

@export_subgroup("Numbers")
@export_enum("A","B","C") var coolEnum = "A":
	set(val):
		coolEnum = val
		notify_property_list_changed()
		
var shinyValue = null

func _get_property_list():
	var properties = []
	
	match coolEnum:
		"A":
			properties.append({
				"name": "Custom_Modulate",
				"type": TYPE_COLOR,
				"hint": PROPERTY_HINT_COLOR_NO_ALPHA
			})
		_:
			shinyValue = null
	return properties

func _get(property):
	if property.begins_with("Custom_"):
		return shinyValue
	
func _set(property, value):
	if property.begins_with("Custom_"):
		shinyValue = value
		return true
	return false
