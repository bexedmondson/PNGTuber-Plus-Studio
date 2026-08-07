class_name EditControls
extends Control

@export var main : Node

@export var spriteViewer : Control
@export var spriteList : Node2D

@export var screenCoverCollisionShape2D : CollisionShape2D

@export var areaMoveEditMenuUp : Area2D
@export var areaMoveEditMenuDown : Area2D

@export var fileDialog : FileDialog
@export var replaceDialog : FileDialog
@export var saveDialog : FileDialog
@export var loadDialog : FileDialog



@onready var addButton = $HBoxContainer/Add/addButton
@onready var addSprite = $HBoxContainer/Add/Fancy3

@onready var linkButton = $HBoxContainer/Link/linkButton
@onready var linkSprite = $HBoxContainer/Link/Fancy2

@onready var saveButton = $HBoxContainer/Save/saveButton
@onready var saveSprite = $HBoxContainer/Save/Fancy4

@onready var loadButton = $HBoxContainer/Load/loadButton
@onready var loadSprite = $HBoxContainer/Load/Fancy5

@onready var repButton = $HBoxContainer/ReplaceSprite/replaceButton
@onready var repSprite = $HBoxContainer/ReplaceSprite/Fancy6

@onready var dupButton = $HBoxContainer/DuplicateSprite/duplicateButton
@onready var dupSprite = $HBoxContainer/DuplicateSprite/Fancy

@onready var buttons = [addButton,linkButton,saveButton,loadButton,repButton,dupButton]
@onready var sprites = [addSprite,linkSprite,saveSprite,loadSprite,repSprite,dupSprite]

func enter_edit_mode():
	spriteViewer.visible = true

func exit_edit_mode():
	spriteViewer.visible = false

func _process(delta):
	return
	var newColor = Color.DARK_SLATE_GRAY if Global.heldSprite == null else Color.WHITE

	linkSprite.get_parent().modulate = newColor
	repSprite.get_parent().modulate = newColor
	dupSprite.get_parent().modulate = newColor

	if areaMoveEditMenuUp.overlaps_area(Global.mouse.area):
		Global.spriteEdit.position.y += (delta*432.0)
	elif areaMoveEditMenuDown.overlaps_area(Global.mouse.area):
		Global.spriteEdit.position.y -= (delta*432.0)

func _on_replace_dialog_visibility_changed():
	pass
	#screenCoverCollisionShape2D.disabled = !replaceDialog.visible

func _notification(what):
	if what == CanvasItem.NOTIFICATION_DRAW:
		$MoveMenuDown.position.y = get_window().size.y


func _on_link_button_pressed():
	Global.reparentMode = true
	Global.chain.enable(Global.reparentMode)

	Global.pushUpdate("Linking sprite...")

#Opens File Dialog
func _on_add_button_pressed():
	fileDialog.visible = true


func _on_save_button_pressed():
	saveDialog.visible = true


func _on_load_button_pressed():
	loadDialog.visible = true


func _on_replace_button_pressed():
	if Global.heldSprite == null:
		return
	replaceDialog.visible = true

func _on_duplicate_button_pressed():
	if Global.heldSprite == null:
		return
	var rand = RandomNumberGenerator.new()
	var id = rand.randi()

	var sprite = main.spriteObject.instantiate()
	sprite.path = Global.heldSprite.path
	sprite.id = id
	sprite.parentId = Global.heldSprite.parentId

	sprite.dragSpeed = Global.heldSprite.dragSpeed
	sprite.showOnTalk = Global.heldSprite.showOnTalk
	sprite.showOnBlink = Global.heldSprite.showOnBlink
	sprite.z = Global.heldSprite.z

	sprite.xFrq = Global.heldSprite.xFrq
	sprite.xAmp = Global.heldSprite.xAmp
	sprite.yFrq = Global.heldSprite.yFrq
	sprite.yAmp = Global.heldSprite.yAmp

	sprite.rdragStr = Global.heldSprite.rdragStr

	sprite.offset = Global.heldSprite.offset

	sprite.rLimitMin = Global.heldSprite.rLimitMin
	sprite.rLimitMax = Global.heldSprite.rLimitMax

	sprite.frames = Global.heldSprite.frames
	sprite.animSpeed = Global.heldSprite.animSpeed

	sprite.costumeLayers = Global.heldSprite.costumeLayers

	main.origin.add_child(sprite)
	sprite.position = Global.heldSprite.position + Vector2(16,16)

	Global.heldSprite = sprite

	Global.spriteList.updateData()

	Global.pushUpdate("Duplicated sprite.")

#SAVE AVATAR
func _on_save_dialog_file_selected(path):
	var data = {}
	var nodes = get_tree().get_nodes_in_group("saved")
	var id = 0
	for child in nodes:

		if child.type == "sprite":
			data[id] = {}
			data[id]["type"] = "sprite"
			data[id]["path"] = child.path
			data[id]["imageData"] = Marshalls.raw_to_base64(child.imageData.save_png_to_buffer())
			data[id]["identification"] = child.id
			data[id]["parentId"] = child.parentId

			data[id]["pos"] = var_to_str(child.position)
			data[id]["offset"] = var_to_str(child.offset)
			data[id]["zindex"] = child.z

			data[id]["drag"] = child.dragSpeed

			data[id]["xFrq"] = child.xFrq
			data[id]["xAmp"] = child.xAmp
			data[id]["yFrq"] = child.yFrq
			data[id]["yAmp"] = child.yAmp

			data[id]["rotDrag"] = child.rdragStr

			data[id]["showTalk"] = child.showOnTalk
			data[id]["showBlink"] = child.showOnBlink

			data[id]["rLimitMin"] = child.rLimitMin
			data[id]["rLimitMax"] = child.rLimitMax

			data[id]["costumeLayers"] = var_to_str(child.costumeLayers)

			data[id]["stretchAmount"] = child.stretchAmount

			data[id]["ignoreBounce"] = child.ignoreBounce

			data[id]["frames"] = child.frames
			data[id]["animSpeed"] = child.animSpeed

			data[id]["clipped"] = child.clipped

			data[id]["toggle"] = child.toggle

			data[id]["randomizeAnim"] = child.randomizeAnim
			data[id]["randomizeSpeed"] = child.randomizeSpeed

			data[id]["minRandSpeed"] = child.minRandSpeed
			data[id]["maxRandSpeed"] = child.maxRandSpeed

			data[id]["resetAnimOnChange"] = child.resetAnimOnChange

			data[id]["costumeChanges"] = child.costumeChanges
			data[id]["microphoneToggles"] = child.microphoneToggles
			data[id]["soundToggles"] = child.soundToggles

		id += 1

	Saving.settings["lastAvatar"] = path

	Saving.data = data.duplicate()
	Saving.write_save(path)

	Global.pushUpdate("Saved avatar at: " + path)


func _on_replace_dialog_file_selected(path):
	Global.heldSprite.replaceSprite(path)
	Global.spriteList.updateData()
	Global.pushUpdate("Replacing sprite with: " + path)

#Runs when selecting image in File Dialog
func _on_file_dialog_file_selected(path):
	main.add_image(path)

func _on_load_dialog_load_selected(path):
	main.on_load_dialog_file_selected(path)
