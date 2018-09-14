extends KinematicBody2D

class Living:
	var initial_hp
	var hp
	var mp
	var type
	var atk
	var tries
	func _init(info):
		self.hp = info['hp']
		self.initial_hp = hp
		self.mp = info['mp']
		self.type = info['type']
		self.atk = info['atk']
		self.tries = 3 # Heart number
		SharedVars.set_tries(tries)
		
	func getHp():
		return self.hp
	
	func setHp(hp):
		self.hp = hp
	
	func takeDemage(hp):
		self.hp -= hp
	
	func isDead():
		return self.hp <= 0
	
	func atack():
		var dice = int(rand_range(1,7))
		return (self.atk * dice) 
	
	func try_revive():
		if tries > 1:
			self.hp = self.initial_hp
			tries -= 1
			SharedVars.set_tries(tries)
			print('Restando ' + str(tries))
			return true
		return false
	