extends Node
# Enemey preloading
var enemy = preload("res://scenes/Enemy.tscn")

# Onready vars

onready var HUD = get_node("canvas").get_node("HUD")
onready var canvas = get_node("canvas")
onready var player = get_node("Player_node").get_node("player_body")

# Stage nums
var stages_info = [
	{
		"level": 1,
		"num_inimigos": 9
	},
	{
		"level": 2,
		"num_inimigos": 12
	},
	{
		"level": 3,
		"num_inimigos": 20
	},
	{
		"level": 4,
		"num_inimigos": 34
	}
]
var num_stage
# enemy vars
var enemys_dead

# Timer var
var timer
var interval = 0
func _fixed_process(delta):
	if ( num_stage <= 3 ):
		set_new_scenario(num_stage)
	elif ( enemys_dead == stages_info[3]["num_inimigos"] ):
		player.end_game()
		canvas.get_node("death_container/death_text").hide()
		canvas.get_node("death_container").show()
		canvas.get_node("death_container/Win_Text").show()
	pass
				
func set_new_scenario(num):
	if (stages_info[num_stage - 1]['num_inimigos'] == enemys_dead):
		timer = int(canvas.get_node("timer").get_text())
		if ( timer == 0 ):
			num_stage += 1
			set_enemys(num_stage)
			canvas.get_node("timer").hide()
			canvas.get_node("timer").set_text(str(3))
			enemys_dead = 0
		else:
			if interval % 40 == 0:
				timer = int(canvas.get_node("timer").get_text())
				timer -= 1
				canvas.get_node("timer").set_text(str(timer))
			interval += 1		
			canvas.get_node("timer").show()
	pass
	
func set_enemys(num_cenario):
	var pointers = get_node("Scenario/Enemy_pos_stage" + str(num_cenario)).get_children()
	var child_num = pointers.size()
	for enemys in range(child_num):
		var before_new_chield = get_children().size()
		var monster = enemy.instance()
		var pos = pointers[enemys].get_pos()
		monster.set_pos(pos)
		add_child(monster)
		get_child(before_new_chield).get_node("Enemy").connect("enemy_is_dead", self, "enemy_dead")


func enemy_dead():
	enemys_dead += 1

func _ready():
	set_enemys(1)
	#player.connect("player_died", self, "is_player_dead")
	enemys_dead = 0
	num_stage = 1
	set_fixed_process(true)
	canvas.get_node("timer").hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	pass


