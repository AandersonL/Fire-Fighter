extends "Living.gd"

# Player variables
var velocity = Vector2(0,0) # (x,y)
var moviment_x
var moviment_y
var left
var right
var down
var up
var atk
var is_atacking = false
var is_walking = false
var side = "down"
var new_animation
var animation

# Constants variables 
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_FRICTION = 20
const MOVIMENT_SPEED = 150
const ACCEL = 0.5

# Onready vars
onready var anim_move = get_node("anim_mov")
onready var metrics = Vector2(Globals.get("display/width"), Globals.get("display/height"))
onready var sprite = get_node("Sprite")

# Classes
var Player
# Battle vars
var enemy
var last_hp
var is_dead = false
# Hud vars
var score
var endgame = false
# signals
signal player_died

func _fixed_process(delta):
	sprite.set_modulate(Color("ffffff"))
	if ( !endgame ):
		SharedVars.player_life = Player.getHp()
		if ( !is_dead ):
			if( !is_atacking() ):
				move_player( delta )
				change_sprite()
				
			verify_atk()
			change_anim()
		check_life()
	else:
		anim_move.play("idle_down")
	pass	
	
func move_player(delta):
	velocity += velocity * delta
	velocity = move_and_slide(velocity, FLOOR_NORMAL, SLOPE_FRICTION)
	
	left = Input.is_action_pressed( "ui_left" ) && get_global_pos().x > sprite.get_region_rect().size.width
	right = Input.is_action_pressed( "ui_right" ) && get_global_pos().x < metrics.width - sprite.get_region_rect().size.width
	down = Input.is_action_pressed( "ui_down" ) && get_global_pos().y < metrics.height - sprite.get_region_rect().size.height
	up = Input.is_action_pressed( "ui_up" ) && get_global_pos().y > sprite.get_region_rect().size.height
	
	### Moviment logic
	moviment_x = 0
	moviment_y = 0
	
	if ( left ):
		moviment_x -= 1
	if ( right ):
		moviment_x += 1
	if ( up ):
		moviment_y -= 1
	if ( down ):
		moviment_y += 1
	
	if ( moviment_x != 0 || moviment_y != 0 ):
		is_walking = true
	else:
		is_walking = false
		
	moviment_x *= MOVIMENT_SPEED
	moviment_y *= MOVIMENT_SPEED
	
	velocity.x = lerp( velocity.x, moviment_x, ACCEL )
	velocity.y = lerp( velocity.y, moviment_y, ACCEL )
	pass

func change_sprite():
	if ( up ):
		side = "up"
	if ( down ):
		side = "down"
	if ( left ):
		side = "left"
	if ( right ):
		side = "right"
	
	if (!is_walking && !atk):
		new_animation = "idle_" + side
	else:
		new_animation = "walk_" + side
	pass

func verify_atk():
	atk = Input.is_action_pressed( "ui_atk" )
	if ( atk ):
		new_animation = "atk_" + side
		if ( enemy != null ):
			enemy.takeDemage(Player.atack()/5)
			#enemy.takeDemage(1000)	
		lock_atk()
	pass
	
func change_anim():
	if ( new_animation != animation ):
		anim_move.play(new_animation)
		animation = new_animation
	pass


func check_life():
#	if (Input.is_action_pressed("morre")) :
#		Player.setHp(1)
	if ( last_hp > Player.getHp() ): # Get demage
		sprite.set_modulate(Color("ff0000"))
	if ( Player.getHp() <= 0.0 ):
		if ( Player.try_revive() ):
			SharedVars.set_player_life( Player.getHp() )
		else:
			is_dead = true
			new_animation = "death_" + side
			change_anim()
			emit_signal("player_died")			
	last_hp = Player.getHp()
	
### Callback functions

func lock_atk():
	is_atacking = true
	pass
	
func free_atk():
	is_atacking = false
	pass

func is_atacking():
	return is_atacking

func _ready():
	randomize()
	Player = Living.new({
		"hp": rand_range(50,80),
		"mp": rand_range(5,10),
		"atk": rand_range(1,3),
		"type": "player"
	})
	last_hp = Player.getHp()
	score = 0
	SharedVars.player_life = Player.getHp()
	SharedVars.score = 0
	get_node("area").add_to_group(Constants.PLAYER)
	set_fixed_process(true)
	pass

func _on_area_area_enter( area ):
	if ( area.is_in_group(Constants.ENEMY)):
		enemy = weakref(area.get_owner().get_node("Enemy").enemy).get_ref()
	pass 

func _on_area_area_exit( area ):
	if ( area.is_in_group(Constants.ENEMY) ):
		enemy = null
	pass 
	
	
	
	
##################### OTHER FUNCTIONS ##################################

func get_points():
	return score

func set_point(point):
	score += point

func end_game():
	endgame = true

func is_end():
	return endgame