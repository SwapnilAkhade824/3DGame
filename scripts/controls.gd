extends Container
class_name controls

@onready var uiMain = $main
@onready var uiIngame = $ingame
@onready var uiPaused = $paused
@onready var uiWon = $won
@onready var uiLost = $lost
@onready var game = $".."
@onready var map = $"../DungeonGenerator3D"

# display content labels
@onready var key_label = uiIngame.get_node("KeyLabel")
@onready var message_label = uiIngame.get_node("Message")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# making the cursor visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# pausing the game
	get_tree().paused = true
	# connecting the buttons 
	# main ui 
	uiMain.get_node("StartButton").connect("pressed",_on_start_pressed)
	uiMain.get_node("RegenerateButton").connect("pressed",_on_regeneration_pressed)
	# ingame screen
	uiIngame.get_node("ExitButton").connect("pressed",_on_exit_pressed)
	uiIngame.get_node("PauseButton").connect("pressed",_on_pause_pressed)
	uiIngame.get_node("RestartButton").connect("pressed",_on_restart_pressed)
	# lost screen
	uiLost.get_node("ExitButton").connect("pressed",_on_exit_pressed)
	uiLost.get_node("PlayAgainButton").connect("pressed",_on_restart_pressed)
	# won screen
	uiWon.get_node("ExitButton").connect("pressed",_on_exit_pressed)
	uiWon.get_node("PlayAgainButton").connect("pressed",_on_restart_pressed)
	# paused screen
	uiPaused.get_node("ExitButton").connect("pressed",_on_exit_pressed)
	uiPaused.get_node("ResumeButton").connect("pressed",_on_resume_pressed)
	# start by main screen
	show_screen("main")
	
func _process(delta: float) -> void:
	# collected item data
	key_label.text = "🗝️ :  %d" % game.keys_collected
	# message block
	message_label.text = game.message
	message_label.visible = (message_label.text != "")
	
func show_screen(screen_name):
	uiMain.visible = (screen_name == "main")
	uiIngame.visible = (screen_name == "ingame")
	uiLost.visible = (screen_name == "lost")
	uiWon.visible = (screen_name == "won")
	uiPaused.visible = (screen_name == "pause")
	
	if screen_name == "ingame": 
		get_tree().paused = false
		game.spawn_player()
	
	else: 
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_start_pressed():
	game._access_the_rooms()
	show_screen("ingame")
	print("Start Pressed")
	
func _on_exit_pressed():
	show_screen("main")
	reset_game()
	print("Exit Pressed")
	
func _on_pause_pressed():
	show_screen("pause")
	print("Pause Pressed")
	
func _on_restart_pressed():
	show_screen("ingame")
	reset_game()
	print("Restart Pressed")
	
func _on_resume_pressed():
	show_screen("ingame")
	print("Resume Pressed")
	
func _on_regeneration_pressed():
	AutoLoad.Seed = randi()
	game.generate_new_map()
	print("Regeneration Pressed")
	
func end_game(case):
	if case == "lost":
		show_screen("lost")
	elif case == "won":
		show_screen("won")
	
func reset_game():
	get_tree().reload_current_scene()
