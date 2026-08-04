extends Button

@export var micInputSelect : MicInputSelect

func _on_microphone_menu_button_pressed():
	if !micInputSelect.visible:
		micInputSelect.setupMicMenu()
	
	micInputSelect.visible = !micInputSelect.visible
