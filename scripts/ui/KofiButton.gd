extends Node

@export var url : String

func _on_kofi_pressed():
	OS.shell_open(url)
	Global.pushUpdate("Support me on ko-fi!")
