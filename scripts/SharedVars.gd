extends Node

### This script with save all variables in game, like score, life.. ##3

var score
var player_life
var players_tries

func set_player_life( life ):
	player_life = life
	
func get_player_life():
	return player_life

func get_points():
	return str(score)
	
func get_tries():
	return players_tries

func set_tries(tries):
	players_tries = tries
	
func _ready():
	score = 0	
	pass
