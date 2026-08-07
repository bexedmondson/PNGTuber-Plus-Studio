extends Node2D

var editMode = true

#Node Reference
@export var originMotion : Node2D
@export var origin : Node2D
@export var camera : Camera2D

@export var mainUI : Control
@export var editControls : EditControls 
@export var tutorial : Control
@export var viewerArrows : Node2D
@export var audioDialog : FileDialog

@export var lines : Control

@export var settingsMenu : SettingsMenu 

@export var pushUpdates : Control

@export var shadow : Node2D 

@export var volumeSlider : Slider
@export var sensitiveSlider : Slider

@export var failedToAddSpriteMessage : Control

@export var zoomLabel : Label

@export var arrowsDown : Sprite2D
@export var arrowsUp : Sprite2D

#Scene Reference
@onready var spriteObject = preload("res://ui_scenes/selectedSprite/spriteObject.tscn")

var saveLoaded = false

#Motion
var yVel = 0
var bounceSlider = 250
var bounceGravity = 1000

#Costumes
var costume = 1
var bounceOnCostumeChange = false

#Zooming
var scaleOverall = 100

var bounceChange = 0.0

#IMPORTANT
var fileSystemOpen = false

#background input capture
signal emptiedCapture
signal pressedKey
var costumeKeys = ["1","2","3","4","5","6","7","8","9","0"]
signal spriteVisToggles(keysPressed:Array)

func _ready():
	Global.main = self
	Global.fail = failedToAddSpriteMessage
	
	
	Global.connect("startSpeaking",onSpeak)
	
	if Saving.settings["newUser"]:
		on_load_dialog_file_selected("default")
		Saving.settings["newUser"] = false
		saveLoaded = true
	else:
		on_load_dialog_file_selected(Saving.settings["lastAvatar"])
		
		volumeSlider.value = Saving.settings["volume"]
		sensitiveSlider.value = Saving.settings["sense"]
		
		get_window().size = str_to_var(Saving.settings["windowSize"])
		
		if Saving.settings.has("bounce"):
			bounceSlider = Saving.settings["bounce"]
		else:
			Saving.settings["bounce"] = 250
		
		if Saving.settings.has("maxFPS"):
			Engine.max_fps = Saving.settings["maxFPS"]
		else:
			Saving.settings["maxFPS"] = 60
		
		if Saving.settings.has("backgroundColor"):
			Global.backgroundColor = str_to_var(Saving.settings["backgroundColor"])
		else:
			Saving.settings["backgroundColor"] = var_to_str(Color(0.0,0.0,0.0,0.0))
		
		if Saving.settings.has("filtering"):
			Global.filtering = Saving.settings["filtering"]
		else:
			Saving.settings["filtering"] = false
			
		if Saving.settings.has("gravity"):
			bounceGravity = Saving.settings["gravity"]
		else:
			Saving.settings["gravity"] = 1000
		
		if Saving.settings.has("costumeKeys"):
			costumeKeys = Saving.settings["costumeKeys"]
		else:
			Saving.settings["costumeKeys"] = costumeKeys
		
		if Saving.settings.has("blinkSpeed"):
			Global.blinkSpeed = Saving.settings["blinkSpeed"]
		else:
			Saving.settings["blinkSpeed"] = 1.0
		
		if Saving.settings.has("blinkChance"):
			Global.blinkChance = Saving.settings["blinkChance"]
		else:
			Saving.settings["blinkChance"] = 200
		
		if Saving.settings.has("bounceOnCostumeChange"):
			bounceOnCostumeChange = Saving.settings["bounceOnCostumeChange"]
		else:
			Saving.settings["bounceOnCostumeChange"] = false
		
		saveLoaded = true
		
	RenderingServer.set_default_clear_color(Global.backgroundColor)
	swapMode()
	settingsMenu.setup()
	changeCostume(1)
	
	var s = get_viewport().get_visible_rect().size
	origin.position = s*0.5
	camera.position = origin.position
	
func _process(delta):
	var hold = origin.get_parent().position.y
	
	origin.get_parent().position.y += yVel * 0.0166
	if origin.get_parent().position.y > 0:
		origin.get_parent().position.y = 0
	bounceChange = hold - origin.get_parent().position.y
	
	yVel += bounceGravity*0.0166
	
	if Input.is_action_just_pressed("openFolder"):
		OS.shell_open(ProjectSettings.globalize_path("user://"))
	
	moveSpriteMenu(delta)
	zoomScene()
	
	fileSystemOpen = isFileSystemOpen()
	
	followShadow()
	
	

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_pressed("middle_wheel"):
		Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		
		if event is InputEventMouseMotion:
			Global.dragging = true
			origin.position += event.screen_relative
		else:
			Global.dragging = false
			
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		Global.dragging = false

func followShadow():
	shadow.visible = is_instance_valid(Global.heldSprite)
	if !shadow.visible:
		return
	
	shadow.global_position = Global.heldSprite.sprite.global_position + Vector2(6,6)
	shadow.global_rotation = Global.heldSprite.sprite.global_rotation
	shadow.offset = Global.heldSprite.sprite.offset
		
	shadow.texture = Global.heldSprite.sprite.texture
	shadow.hframes = Global.heldSprite.sprite.hframes
	shadow.frame = Global.heldSprite.sprite.frame
	

func isFileSystemOpen():
	for obj in get_tree().get_nodes_in_group("filedialog"):
		if obj.visible:
			if obj != audioDialog:# and obj != replaceDialog:
				Global.heldSprite = null
			return true
	return false

#Displays control panel whether or not application is focused
func _notification(what):
	match what:
		SceneTree.NOTIFICATION_APPLICATION_FOCUS_OUT:
			mainUI.visible = false
			pushUpdates.visible = false
		SceneTree.NOTIFICATION_APPLICATION_FOCUS_IN:
			if !editMode:
				mainUI.visible = true
			pushUpdates.visible = true
		CanvasItem.NOTIFICATION_DRAW:
			onWindowSizeChange()

func onWindowSizeChange():
	if !saveLoaded:
		return
	Saving.settings["windowSize"] = var_to_str(get_window().size)
	var s = get_viewport().get_visible_rect().size
	origin.position = s*0.5
	
	camera.position = origin.position
	viewerArrows.position = editControls.position

func zoomScene():
	#Handles Zooming
	if Input.is_action_pressed("control"):
		if Input.is_action_just_pressed("scrollUp"):
			if scaleOverall < 400:
				camera.zoom += Vector2(0.1,0.1)
				scaleOverall += 10
				changeZoom()
		if Input.is_action_just_pressed("scrollDown"):
			if scaleOverall > 10:
				camera.zoom -= Vector2(0.1,0.1)
				scaleOverall -= 10
				changeZoom()
	
	zoomLabel.modulate.a = lerp(zoomLabel.modulate.a,0.0,0.02)
	
func changeZoom():
	var newZoom = Vector2(1.0,1.0) / camera.zoom
	#controlPanel.scale = newZoom
	tutorial.scale = newZoom
	editControls.scale = newZoom
	viewerArrows.scale = newZoom
	lines.scale = newZoom
	pushUpdates.scale = newZoom
	Global.mouse.scale = newZoom

	zoomLabel.modulate.a = 6.0
	zoomLabel.text = "Zoom : " + str(scaleOverall) + "%"
	
	Global.pushUpdate("Set zoom to " + str(scaleOverall) + "%")
	onWindowSizeChange()
	
#When the user speaks!
func onSpeak():
	if origin.get_parent().position.y > -16:
		yVel = bounceSlider * -1

#Swaps between edit mode and view mode
func swapMode():
	
	Global.heldSprite = null
	
	editMode = !editMode
	Global.pushUpdate("Toggled editing mode.")
	
	get_viewport().transparent_bg = !editMode
	if Global.backgroundColor.a != 0.0:
		get_viewport().transparent_bg = false
	RenderingServer.set_default_clear_color(Global.backgroundColor)
	
	#processing
	editControls.set_process(editMode)
	mainUI.set_process(!editMode)
	
	#visibility
	editControls.visible = editMode
	
	if editMode:
		editControls.enter_edit_mode()
	else:
		editControls.exit_edit_mode()
		
	tutorial.visible = editMode
	mainUI.visible = !editMode
	lines.visible = editMode
	
#Adds sprite object to scene
func add_image(path):
	
	var rand = RandomNumberGenerator.new()
	var id = rand.randi()
	
	var sprite = spriteObject.instantiate()
	sprite.path = path
	sprite.id = id
	origin.add_child(sprite)
	sprite.position = Vector2.ZERO
	
	Global.spriteList.updateData()
	
	Global.pushUpdate("Added new sprite.")


#LOAD AVATAR
func on_load_dialog_file_selected(path):
	var data = Saving.read_save(path)
	
	if data == null:
		return
	
	origin.queue_free()
	var new = Node2D.new()
	originMotion.add_child(new)
	origin = new
	
	Global.toggleMicrophone(true)
	
	for item in data:
		var sprite = spriteObject.instantiate()
		sprite.path = data[item]["path"]
		sprite.id = data[item]["identification"]
		sprite.parentId = data[item]["parentId"]
		
		sprite.offset = str_to_var(data[item]["offset"])
		sprite.z = data[item]["zindex"]
		sprite.dragSpeed = data[item]["drag"]
		sprite.originalDragSpeed = data[item]["drag"]
		
		sprite.xFrq = data[item]["xFrq"]
		sprite.xAmp = data[item]["xAmp"]
		sprite.yFrq = data[item]["yFrq"]
		sprite.yAmp = data[item]["yAmp"]
		
		sprite.rdragStr = data[item]["rotDrag"]
		sprite.showOnTalk = data[item]["showTalk"]
		
		sprite.showOnBlink = data[item]["showBlink"]
		
		if data[item].has("rLimitMin"):
			sprite.rLimitMin = data[item]["rLimitMin"]
		if data[item].has("rLimitMax"):
			sprite.rLimitMax = data[item]["rLimitMax"]
		
		if data[item].has("costumeLayers"):
			sprite.costumeLayers = str_to_var(data[item]["costumeLayers"]).duplicate()
			if sprite.costumeLayers.size() < 8:
				for i in range(5):
					sprite.costumeLayers.append(1)

		if data[item].has("stretchAmount"):
			sprite.stretchAmount = data[item]["stretchAmount"]
		
		if data[item].has("ignoreBounce"):
			sprite.ignoreBounce = data[item]["ignoreBounce"]
		
		if data[item].has("frames"):
			sprite.frames = data[item]["frames"]
		if data[item].has("animSpeed"):
			sprite.animSpeed = data[item]["animSpeed"]
		if data[item].has("imageData"):
			sprite.loadedImageData = data[item]["imageData"]
		if data[item].has("clipped"):
			sprite.clipped = data[item]["clipped"]
		if data[item].has("toggle"):
			sprite.toggle = data[item]["toggle"]
		
		if data[item].has("randomizeAnim"):
			sprite.randomizeAnim = data[item]["randomizeAnim"]
		if data[item].has("randomizeSpeed"):
			sprite.randomizeSpeed = data[item]["randomizeSpeed"]
		
		if data[item].has("minRandSpeed"):
			sprite.minRandSpeed = data[item]["minRandSpeed"]
		if data[item].has("maxRandSpeed"):
			sprite.maxRandSpeed = data[item]["maxRandSpeed"]
			
		if data[item].has("resetAnimOnChange"):
			sprite.resetAnimOnChange = data[item]["resetAnimOnChange"]
		
		if data[item].has("costumeChanges"):
			sprite.costumeChanges = data[item]["costumeChanges"]
		if data[item].has("microphoneToggles"):
			sprite.microphoneToggles = data[item]["microphoneToggles"]
		if data[item].has("soundToggles"):
			sprite.soundToggles = data[item]["soundToggles"]
			loadEvents(sprite) #If soundToggles exists, then the other two maps will too
		
		origin.add_child(sprite)
		sprite.position = str_to_var(data[item]["pos"])
		
	
	changeCostume(1)
	Saving.settings["lastAvatar"] = path
	Global.spriteList.updateData()
	
	Global.pushUpdate("Loaded avatar at: " + path)
	
	onWindowSizeChange()


#LOAD EVENTS
func loadEvents(sprite):
	iterateEvents(sprite, sprite.costumeChanges, Global.eventTypes.CHANGE_COSTUME)
	iterateEvents(sprite, sprite.microphoneToggles, Global.eventTypes.TOGGLE_MICROPHONE)
	iterateAudioEvents(sprite, sprite.soundToggles, Global.eventTypes.PLAY_SOUND)


func iterateEvents(sprite, map, type):
	for frame in map:
		var newRow = Global.menuRowItem.instantiate()
		if newRow != null:
			newRow.eventType = type
			Global.menuItemsContainer.add_child(newRow)
			newRow.eventData = map[frame]
			newRow.frameInput.text = str(frame)
			newRow.frameIndex = frame
			newRow.assignedSprite = sprite
			

func iterateAudioEvents(sprite, map, type):
	for frame in map:
		var newRow = Global.menuRowItem.instantiate()
		if newRow != null:
			
			if typeof(map[frame][1]) == TYPE_STRING:
				var newAssignment = [null, [map[frame][1], 0, null]]
				map[frame] = newAssignment
			
			if len(map[frame][1]) == 2:
				map[frame][1].append(null)

			newRow.eventType = type
			Global.menuItemsContainer.add_child(newRow)
			newRow.setUpAudioEvent(map[frame][1][0], map[frame][1][1], map[frame][1][2])
			map[frame] = newRow.eventData
			newRow.frameInput.text = str(frame)
			newRow.frameIndex = frame
			newRow.assignedSprite = sprite


func changeCostume(newCostume):
	if newCostume == null:
		return
	
	if Global.resetMicOnCostumeChange:
		Global.toggleMicrophone(true)

	costume = newCostume
	#Global.heldSprite = null
	var nodes = get_tree().get_nodes_in_group("saved")
	for sprite in nodes:
		if sprite.costumeLayers[newCostume-1] == 1:
			sprite.visible = true
			sprite.changeCollision(true)
			sprite.eventChecked = false
		else:
			sprite.visible = false
			sprite.changeCollision(false)
	Global.spriteEdit.layerSelected() #costumeChanged signal is emitted here
	#spriteList.updateAllVisible()
	
	if bounceOnCostumeChange:
		onSpeak()
	
	Global.pushUpdate("Change costume: " + str(newCostume))
	
func moveSpriteMenu(delta):
	#moves sprite viewer editor thing around
	
	if !Global.spriteEdit.visible:
		arrowsDown.visible = false
		arrowsUp.visible = false
		return

	var size = get_viewport().get_visible_rect().size

	var windowLength = 1250 #1187

	arrowsDown.position.y =  size.y - 25
	
	if size.y > windowLength+50:
		Global.spriteEdit.position.y = 66
		
		arrowsDown.visible = false
		arrowsUp.visible = false
		return
	
	arrowsUp.visible = Global.spriteEdit.position.y < 16
	arrowsDown.visible = Global.spriteEdit.position.y > size.y-windowLength+2
	
	if Global.spriteEdit.position.y > 66:
		Global.spriteEdit.position.y = 66
	elif Global.spriteEdit.position.y < size.y-windowLength:
		Global.spriteEdit.position.y = size.y-windowLength


func _on_settings_buttons_pressed():
	settingsMenu.visible = !settingsMenu.visible


func _on_background_input_capture_bg_key_pressed(node, keys_pressed):
	var keyStrings = []
	
	for i in keys_pressed:
		if keys_pressed[i]:
			keyStrings.append(OS.get_keycode_string(i) if !OS.get_keycode_string(i).strip_edges().is_empty() else "Keycode" + str(i))
	
	if fileSystemOpen:
		return
	
	if keyStrings.size() <= 0:
		emit_signal("emptiedCapture")
		return
	
	if settingsMenu.awaitingCostumeInput >= 0:
		
		if keyStrings[0] == "Keycode1":
			if !settingsMenu.hasMouse:
				emit_signal("pressedKey")
				return
		
		var currentButton = costumeKeys[settingsMenu.awaitingCostumeInput]
		costumeKeys[settingsMenu.awaitingCostumeInput] = keyStrings[0]
		Saving.settings["costumeKeys"] = costumeKeys
		Global.pushUpdate("Changed costume " + str(settingsMenu.awaitingCostumeInput+1) + " hotkey from \"" + currentButton + "\" to \"" + keyStrings[0] + "\"")
		emit_signal("pressedKey")
	
	for key in keyStrings:
		var i = costumeKeys.find(key)
		if i >= 0:
			changeCostume(i+1)
	


func bgInputSprite(node, keys_pressed):
	if fileSystemOpen:
		return
	var keyStrings = []
	
	for i in keys_pressed:
		if keys_pressed[i]:
			keyStrings.append(OS.get_keycode_string(i) if !OS.get_keycode_string(i).strip_edges().is_empty() else "Keycode" + str(i))
	
	if keyStrings.size() <= 0:
		emit_signal("fatfuckingballs")
		return
	
	spriteVisToggles.emit(keyStrings)


func _on_audio_file_dialog_file_selected(path: String) -> void:
	#Global.heldEvent._on_audio_file_selected(path)
	Global.playSoundEditor.filePathInput.text = path
