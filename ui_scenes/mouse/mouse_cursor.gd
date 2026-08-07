extends Node2D

@onready var area = $Area2D

func _ready():
	Global.mouse = self

func _process(delta):
	if Global.main.editMode:
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("mouse_left"):
			#print(area.get_overlapping_areas())
			Global.select(area.get_overlapping_areas())
	
