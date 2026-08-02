class_name SettingsMenu
extends Control

var awaitingCostumeInput = -1

var hasMouse = false

@export var backgroundColorPickerButton : Button
@export var maxFPSValueLabel : Label
@export var maxFPSSlider : Slider
@export var antialiasingCheckbox = CheckBox

@export_group("Bounce")
@export var bounceForceValueLabel : Label
@export var bounceForceSlider : Slider
@export var bounceGravityValueLabel : Label
@export var bounceGravitySlider : Slider

@export_group("Costumes")
@export var costumeButtons : Array[CostumeButton]
@export var bounceOnCostumeChangeButton : Button

@export_group("Blinking")
@export var blinkSpeedValueLabel : Label
@export var blinkSpeedSlider : Slider
@export var blinkChanceValueLabel : Label
@export var blinkChanceSlider : Slider


func setup():
	backgroundColorPickerButton.color = Global.backgroundColor
	if Global.backgroundColor == Color.TRANSPARENT:
		backgroundColorPickerButton.color = Color.WHITE
	
	maxFPSValueLabel.text = str(Engine.max_fps)
	maxFPSSlider.value = Engine.max_fps
	if Engine.max_fps == 0:
		maxFPSValueLabel.text = "Unlimited"
		maxFPSSlider.value = 241
	
	bounceForceValueLabel.text = str(Saving.settings["bounce"])
	bounceForceSlider.value = Saving.settings["bounce"]
	bounceGravityValueLabel.text = str(Saving.settings["gravity"])
	bounceGravitySlider.value = Saving.settings["gravity"]
	
	_on_check_box_toggled(Global.filtering)

	blinkSpeedValueLabel.text = "blink speed: " + str(int(1.0/Global.blinkSpeed))
	blinkSpeedSlider.value = int(1.0/Global.blinkSpeed)

	blinkChanceValueLabel.text = "blink chance: 1 in " + str(Global.blinkChance)
	blinkChanceSlider.value = Global.blinkChance
	
	bounceOnCostumeChangeButton.button_pressed = Global.main.bounceOnCostumeChange
	
	for costumeButton in costumeButtons:
		costumeButton.setup()
	
	
func _on_color_picker_button_color_changed(color):
	get_viewport().transparent_bg = false
	RenderingServer.set_default_clear_color(color)
	Global.backgroundColor = color
	Saving.settings["backgroundColor"] = var_to_str(color)
	
	Global.pushUpdate("Background color set to CUSTOM COLOR.")

func _on_button_pressed():
	get_viewport().transparent_bg = true
	Global.backgroundColor = Color(0.0,0.0,0.0,0.0)
	Saving.settings["backgroundColor"] = var_to_str(Color(0.0,0.0,0.0,0.0))
	
	Global.pushUpdate("Background color set to TRANSPARENT.")

func _on_color_picker_button_picker_created():
	get_viewport().transparent_bg = false
	RenderingServer.set_default_clear_color(backgroundColorPickerButton.color)
	
func _on_fps_drag_value_changed(value):
	if maxFPSSlider.value == 241:
		maxFPSValueLabel.text = "Unlimited"
		return
	maxFPSValueLabel.text = str(value)

func _on_confirm_pressed():
	if maxFPSSlider.value == 241:
		Engine.max_fps = 0
		Saving.settings["maxFPS"] = 0
		Global.pushUpdate("Max fps set to unlimited.")
		return
	Engine.max_fps = maxFPSSlider.value
	Saving.settings["maxFPS"] = maxFPSSlider.value
	
	Global.pushUpdate("Max fps set to " + str(Engine.max_fps) + ".")

func _on_green_button_pressed():
	get_viewport().transparent_bg = false
	Global.backgroundColor = Color.GREEN
	Saving.settings["backgroundColor"] = var_to_str(Color.GREEN)
	RenderingServer.set_default_clear_color(Color.GREEN)
	
	Global.pushUpdate("Background color set to GREEN.")

func _on_blue_button_pressed():
	get_viewport().transparent_bg = false
	Global.backgroundColor = Color.BLUE
	Saving.settings["backgroundColor"] = var_to_str(Color.BLUE)
	RenderingServer.set_default_clear_color(Color.BLUE)
	
	Global.pushUpdate("Background color set to BLUE.")

func _on_magenta_button_pressed():
	get_viewport().transparent_bg = false
	Global.backgroundColor = Color.MAGENTA
	Saving.settings["backgroundColor"] = var_to_str(Color.MAGENTA)
	RenderingServer.set_default_clear_color(Color.MAGENTA)
	
	Global.pushUpdate("Background color set to MAGENTA.")

func _on_check_box_toggled(button_pressed):
	var new = 0
	if button_pressed:
		new = 2
	var nodes = get_tree().get_nodes_in_group("saved")
	for sprite in nodes:
		sprite.sprite.texture_filter = new
	Global.filtering = button_pressed
	Saving.settings["filtering"] = button_pressed
	antialiasingCheckbox.button_pressed = button_pressed
	
	Global.pushUpdate("Texture filtering set to: " + str(button_pressed))

func _on_bounce_force_value_changed(value):
	bounceForceValueLabel.text = str(value)
	Global.main.bounceSlider = value
	Saving.settings["bounce"] = value
	
	Global.pushUpdate("Bounce force value changed.")

func _on_bounce_gravity_value_changed(value):
	bounceGravityValueLabel.text = str(value)
	Global.main.bounceGravity = value
	Saving.settings["gravity"] = value
	
	Global.pushUpdate("Bounce gravity value changed.")

func costumeButtonsPressed(label,id):
	label.text = "AWAITING INPUT"
	await Global.main.emptiedCapture
	awaitingCostumeInput = id - 1
	
	
	await Global.main.pressedKey
	label.text = "costume " + str(id) + " key: \"" + Global.main.costumeKeys[id - 1] + "\""
	await Global.main.emptiedCapture
	awaitingCostumeInput = -1

func _on_blink_speed_value_changed(value):
	if value == 0:
		Global.blinkSpeed = 0.0
		Saving.settings["blinkSpeed"] = 0.0
		blinkSpeedValueLabel.text = "0"
		return
	Global.blinkSpeed = 1.0/float(value)
	Saving.settings["blinkSpeed"] = 1.0/float(value)
	blinkSpeedValueLabel.text = str(value)


func _on_blink_chance_value_changed(value):
	Global.blinkChance = value
	Saving.settings["blinkChance"] = value
	blinkChanceValueLabel.text = "1 in " + str(value)


func _on_costume_check_toggled(button_pressed):
	Global.main.bounceOnCostumeChange = button_pressed
	Saving.settings["bounceOnCostumeChange"] = button_pressed


func _process(delta):
	#var g = to_local(get_global_mouse_position())
	#TODO put this back in?
	var g = 0
	#if g.x < 0 or g.y < 0 or g.x > $NinePatchRect.size.x or g.y > $NinePatchRect.size.y:
#		hasMouse = false
#	else:
#		hasMouse = true

func deleteKey(label,id):
	Global.main.costumeKeys[id-1] = "null"
	label.text = "costume " + str(id) + " key: \"" + Global.main.costumeKeys[id-1] + "\""
	Global.pushUpdate("Deleted costume hotkey " + str(id) + ".")
	

func _on_truncate_check_toggled(button_pressed: bool) -> void:
	Global.truncating = button_pressed


func _on_reset_mic_check_toggled(button_pressed: bool) -> void:
	Global.resetMicOnCostumeChange = button_pressed


func _on_status_updates_check_toggled(button_pressed: bool) -> void:
	Global.updatesEnabled = button_pressed
