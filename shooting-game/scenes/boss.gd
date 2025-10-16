extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D
@export var move_speed = 100
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

# 🩸 Boss health
@export var max_health = 3
var current_health = 3
var dead = false

func _ready():
	current_health = max_health
	if has_node("HealthBar"):
		var bar = $HealthBar
		bar.max_value = max_health
		bar.value = current_health

func _physics_process(delta):
	if dead:
		return

	var dir_to_player = global_position.direction_to(player.global_position)
	velocity = dir_to_player * move_speed
	move_and_slide()
	global_rotation = dir_to_player.angle() + PI / 2.0

	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		player.kill()

# 🧠 Called when the player hits the boss
func kill():
	if dead:
		return

	current_health -= 1
	update_health_bar()

	if current_health <= 0:
		die()
	else:
		$Deathsound.play() # optional sound for being hit

func update_health_bar():
	if has_node("HealthBar"):
		var bar = $HealthBar
		bar.value = current_health

func die():
	dead = true
	Global.score += 1
	$Deathsound.play()
	$Graphics/Dead.show()
	$Graphics/Alive.hide()
	$CollisionShape2D.disabled = true
	if has_node("HealthBar"):
		$HealthBar.hide()
