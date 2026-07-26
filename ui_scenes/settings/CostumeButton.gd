class_name CostumeButton
extends Button

@export var costumeIndex : int
@export var label : Label
@export var settingsMenu : SettingsMenu

func setup():
	label.text = "costume " + str(costumeIndex) + " key: \"" + Global.main.costumeKeys[costumeIndex - 1] + "\""

func _pressed() -> void:
	settingsMenu.costumeButtonsPressed(label,costumeIndex)

func _on_delete_pressed() -> void:
	settingsMenu.deleteKey(label, costumeIndex)
