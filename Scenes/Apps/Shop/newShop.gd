extends Control

@onready var phoneMenu = $"../Ui/Phone"

func _on_upgrade_button_pressed() -> void:
	$MainPage.hide()
	$Results.loadUpgradePurchases()
	$Results.show()
	
func _on_item_button_pressed() -> void:
	$MainPage.hide()
	$Results.loadItemPurchases()
	$Results.show()	

func _on_rods_button_pressed() -> void:
	$MainPage.hide()
	$Results.loadRodPurchases()
	$Results.show()	

func _on_exit_button_pressed() -> void:
	self.hide()
	$PurchasePage.hide()
	$Results.resetPage()
	$Results.hide()
	$MainPage.show()
	phoneMenu.show()


func _on_visibility_changed() -> void:
	pass # Replace with function body.
