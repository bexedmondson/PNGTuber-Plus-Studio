class_name Tutorial
extends Control

@export var tutorialPopupRect : NinePatchRect

var tween = null

func _on_button_pressed():
	if tween != null:
		tween.stop()
	tutorialPopupRect.visible = !tutorialPopupRect.visible
	tutorialPopupRect.scale = Vector2(0.0,0.0)
	tween = get_tree().create_tween()
	tween.tween_property(tutorialPopupRect,"scale",Vector2(1,1),0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
