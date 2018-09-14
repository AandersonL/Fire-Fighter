extends Node2D
# Onready vars
onready var hearts = [get_node("heart1"), get_node("heart2"), get_node("heart3")]
var heart_num = 0
#Player variables
var player_life
var original_life
var porcent_life

func _fixed_process(delta):
	get_node("Score").set_text( "Pontos: " + SharedVars.get_points() )
	set_player_life(SharedVars.get_player_life())

func set_heart(heart):
	porcent_life = player_life / original_life
	if ( porcent_life < 0.9 ):
		heart.set_region_rect(Rect2(80,2,14,13))
	if ( porcent_life < 0.6 ):
		heart.set_region_rect(Rect2(96,2,14,13))
	if ( porcent_life < 0.3 ):
		heart.set_region_rect(Rect2(112,2,14,13))
	if ( porcent_life < 0.1 ):
		heart.set_region_rect(Rect2(128,2,14,13))
	if ( porcent_life >= 1 ):
		heart.set_region_rect(Rect2(64, 2, 14,13))
		 
		
func set_player_life(life):
	player_life = life
	if ( original_life == null ):
		original_life = life
	
	set_heart(hearts[SharedVars.get_tries() - 1])

	
func set_hearts():
	pass
	
func _ready():
	set_fixed_process(true)
	pass
