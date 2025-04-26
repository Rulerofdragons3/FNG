extends Control

var purchase:Purchase
var upgradePath:String
@onready var UIMoney = $"../../Ui/MoneyLabel"

func _on_buy_pressed() -> void:	
	if Globals.money < purchase.price:
		print("Broke...")
		return
	Globals.money -= purchase.price
	purchase.purchase()
	if upgradePath != "":
		Globals.upgrades[upgradePath] = purchase
		upgradePath = ""
	purchase = null
	UIMoney.text = "$" + str("%0.2f" % Globals.money)
	self.hide()
	%Results.refreshPage()
	%Results.show()

func _on_back_button_pressed() -> void:
	self.hide()
	%Results.show() #No need to refresh page
