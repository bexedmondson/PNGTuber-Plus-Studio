extends Node

@export var main : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#ElgatoStreamDeck.on_key_down.connect(changeCostumeStreamDeck)

func changeCostumeStreamDeck(id: String):
	match id:
		"1":main.changeCostume(1)
		"2":main.changeCostume(2)
		"3":main.changeCostume(3)
		"4":main.changeCostume(4)
		"5":main.changeCostume(5)
		"6":main.changeCostume(6)
		"7":main.changeCostume(7)
		"8":main.changeCostume(8)
		"9":main.changeCostume(9)
		"10":main.changeCostume(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
