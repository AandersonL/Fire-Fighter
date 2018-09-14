extends "Living.gd"

# Enemy variables
var velocity = Vector2()
var moviment_x = 0
var moviment_y 
var left
var right
var random_walk
var walk_counter = 120
var counter_atk = 0 # erase after debugger
var enemy #holds object
# onready vars
onready var anim = get_node("Anim")
onready var sprite = get_node("Sprite")

# Enemy Constants
var SPEED_VEL = 2
var FLOOR_NORMAL = Vector2(0, -1)
var SLOPE_FRICTION = 20
var ACCEL = 0.5
var INTERVAL = 1.1 # Interval between actions

# Battle variables
var is_battle = false
var is_colliding = false
var player
var last_hp
var is_dead = false
var is_atacking = false
# State
var state_now
var state

# signals
signal enemy_is_dead

func _fixed_process(delta):
	sprite.set_modulate(Color("ffffff"))
	state.update(delta)
	check_life()

	
func check_life():
	if ( last_hp > enemy.getHp() ):
		sprite.set_modulate(Color("d69393"))
	
	if (enemy.getHp() <= 0 && !is_dead):
		state = Battle.new(self, player)
		anim.play("death")
		is_dead = true
		get_node("shape").queue_free()
		yield(anim, "finished")
		SharedVars.score += 100
		emit_signal("enemy_is_dead")
		queue_free()	
		
	last_hp = enemy.getHp()

	
func verify_anim():
	if ( !is_colliding() ):
		state = null
		state = Fallow.new(self)

func is_colliding():
	return is_colliding

func atacked():
	return is_atacking
	
func make_atack():
	is_atacking = true
func end_atack():
	is_atacking = false

func fallow(delta):
	# Fallow the difference between two vectors2 (x, y)	
	var p_vector = Vector2(player.get_global_pos().x, player.get_global_pos().y)
	var e_vector = Vector2(get_global_pos().x, get_global_pos().y)
	var result = (p_vector - e_vector)
	if ( result.x > 0 ):
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)
	result += result * delta
	move_and_slide(result, FLOOR_NORMAL, SLOPE_FRICTION)
	
func _on_area_area_enter( area ):
	if ( area.is_in_group(Constants.PLAYER) ):
		player = weakref(area.get_owner().get_node("player_body")).get_ref()
		if (! state extends Battle ):
			state = Battle.new(self, player)
		is_colliding = true
		is_battle = true
	elif ( area.is_in_group(Constants.ENEMY) && !is_battle ):
		player = area.get_owner().get_node("Enemy").player
		if ( player != null ):
			player = weakref(player).get_ref()
			state = Fallow.new(self)
			is_battle = true
			is_colliding = false
	pass 


func _on_area_area_exit( area ):
	if ( area.is_in_group(Constants.PLAYER)):
		is_colliding = false
	pass 

func _ready():
	randomize()
	state = WalkState.new(self)
	enemy = Living.new({
		"hp": rand_range(80,100),
		"mp": rand_range(10,20),
		"type": "monster",
		"atk": rand_range(2,5),
	})
	last_hp = enemy.getHp()
	set_fixed_process(true)
	get_node("area").add_to_group(Constants.ENEMY)
	pass

################################ CLASS WALKSTATE #########################################
# read more about states in -> http://gameprogrammingpatterns.com/state.html
class WalkState:
	var enemy
	func _init(enemy):
		self.enemy = enemy
		self.enemy.anim.play("walk")
		pass
	func update(delta):
		self.enemy.velocity += self.enemy.velocity * delta
		self.enemy.velocity = self.enemy.move(self.enemy.velocity)
	
		if ( self.enemy.walk_counter >= 0 && self.enemy.walk_counter <= 150 ):
			self.enemy.moviment_x = 1
			self.enemy.walk_counter += 1
			self.enemy.moviment_x *= self.enemy.SPEED_VEL
			self.enemy.sprite.set_flip_h(true)
		elif ( self.enemy.walk_counter >= 150 && self.enemy.walk_counter <= 300 ):
			self.enemy.moviment_x = -1
			self.enemy.walk_counter += 1
			self.enemy.moviment_x *= self.enemy.SPEED_VEL
			self.enemy.sprite.set_flip_h(false)
		else:
			self.enemy.walk_counter = 0
		
		self.enemy.velocity.x = lerp(self.enemy.velocity.x, self.enemy.moviment_x, self.enemy.ACCEL)
		self.enemy.walk_counter += 1
		pass
################################## Class Fallow State ##################

class Fallow:
	var enemy
	func _init(enemy):
		self.enemy = enemy
		self.enemy.anim.play("charging")
	
	func update(delta):
		self.enemy.fallow(delta)
		pass
		
		
################################## Class Battle State #####################

class Battle:
	var enemy
	var target
	func _init(enemy, target):
		self.enemy = enemy
		self.target = target
		self.enemy.anim.play("atack")
		
	func update(delta):
		if (!self.enemy.is_dead):
			self.enemy.fallow(delta)
		if ( self.enemy.is_colliding() && self.enemy.atacked() ):
			var damage = 1/10
			self.target.Player.takeDemage(0.4)
		pass
