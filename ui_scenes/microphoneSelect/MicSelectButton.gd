extends Control

@export var optionLabel : Label

var _micName : String = ""
var _micInputSelect : MicInputSelect

func setup(micInputSelect : MicInputSelect, micName : String):
	_micInputSelect = micInputSelect
	_micName = micName
	
	optionLabel.text = _micName

func _on_button_pressed():
	if !_micInputSelect.visible:
		return
	
	AudioServer.input_device = _micName
	Global.deleteAllMics()
	Global.currentMicrophone = null
	
	_micInputSelect.visible = false
	
	await get_tree().create_timer(1.0).timeout
	Global.createMicrophone()
	
	
