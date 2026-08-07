class_name ScaleOnInteractButton
extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_entered.connect(_increase_scale)
	self.mouse_exited.connect(_decrease_scale)

func _increase_scale():
	self.scale = lerp(self.scale,Vector2(1.5,1.5),0.2)

func _decrease_scale():
	self.scale = lerp(self.scale,Vector2.ONE,0.2)

func on_pressed():
	self.scale = Vector2(0.6,0.6)