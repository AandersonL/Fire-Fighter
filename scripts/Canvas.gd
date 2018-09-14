extends CanvasLayer

# Screen variables

var screen = Vector2(Globals.get("display/width"), Globals.get("display/height"))

# onready vars
onready var death_label = get_node("death_container")
onready var player = get_owner().get_node("Player_node/player_body")

# Script values
var set_points_screen = false
var screen_points = 0

# Save files

var points_path_file = "res://rank.cfg"

func _fixed_process(delta):
	death_label.set_pos(screen/2)
	if ( set_points_screen || player.is_end() ):
		screen_config()
	pass


func screen_config():
	var total_points = int(SharedVars.get_points() )
	if ( total_points == 0 ):
		get_node("death_container/points").set_text("Pontos: " + str(total_points ))
		
	if ( screen_points < total_points):
		screen_points += 10
		get_node("death_container/points").set_text("Pontos: " + str(screen_points))
	
			
func is_player_dead():
	death_label.show()
	death_label.get_node("Win_Text").hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	set_points_screen = true
	pass

func _ready():
	set_fixed_process(true)
	death_label.hide()
	player.connect("player_died", self, "is_player_dead")
	pass


func _on_Button_pressed():
	get_tree().reload_current_scene()
	pass # replace with function body
