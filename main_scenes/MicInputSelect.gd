class_name MicInputSelect
extends Control

@export var micOptionButtonPlaceholder : Node

var micOptions : Array

func setupMicMenu():
	for micOption in micOptions:
		micOption.queue_free()
	
	var inputList = AudioServer.get_input_device_list()
	for input in inputList:
		var newButton = micOptionButtonPlaceholder.create_instance()
		newButton.setup(self, input)
		micOptions.append(newButton)
