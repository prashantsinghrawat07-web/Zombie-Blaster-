extends CharacterBody2D

@onready var ray_cast_2d = $RayCast2D
@export var move_speed = 200

var dead = false
var shots_fired = 0
var max_shots = 10
var reloading = false
var win_shown = false  # Prevent repeating win text
@onready var healthbar = $CanvasLayer/Healthbar

var hp = 10

func _ready():
	healthbar.value = hp
	# Hide reload label at start
	if $CanvasLayer.has_node("ReloadingLabel"):
		$CanvasLayer/ReloadingLabel.visible = false
	update_ammo_label()

func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	if dead:
		return

	global_rotation = global_position.direction_to(get_global_mouse_position()).angle() + PI / 2.0

	if Input.is_action_just_pressed("shoot"):
		if not reloading:
			shoot()

	var current_scene = get_tree().current_scene
	if not current_scene:
		return

	var path = current_scene.scene_file_path

	# --- Level Progression ---
	if path.ends_with("world.tscn") and Global.score >= 20:
		load_level_2()
	elif path.ends_with("level_2.tscn") and Global.score >= 30:
		load_level_3()
	elif path.ends_with("level_3.tscn") and Global.score >= 35 :
		load_level_4()
	elif path.ends_with("level_4.tscn") and Global.score >= 40 and not win_shown:
		show_you_win()


func _physics_process(delta):
	if dead:
		return
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_dir * move_speed
	move_and_slide()

func kill():
	if dead:
		return

	if healthbar.value <= 0:
		dead = true
		Global.score = 0
		$Death_audio.play()
		$Graphics/Dead.show()
		$Graphics/Alive.hide()
		$CanvasLayer/DeathScreen.show()
	else:
		healthbar.value -= 0.05

func restart():
	get_tree().reload_current_scene()

func load_level_2():
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/level_2.tscn")

func load_level_3():
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/level_3.tscn")
	
func load_level_4():
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/level_4.tscn")

func shoot():
	shots_fired += 1
	update_ammo_label()

	$Flash.show()
	$Flash/Timer.start()
	$shooting_audio2.play()

	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider().has_method("kill"):
		ray_cast_2d.get_collider().kill()

	if shots_fired >= max_shots:
		start_reload()

func start_reload():
	reloading = true
	shots_fired = 0

	if $CanvasLayer.has_node("ReloadingLabel"):
		var label = $CanvasLayer/ReloadingLabel
		label.visible = true
		label.text = "Reloading..."

	update_ammo_label()

	await get_tree().create_timer(3.0).timeout

	if $CanvasLayer.has_node("ReloadingLabel"):
		$CanvasLayer/ReloadingLabel.visible = false

	reloading = false
	update_ammo_label()

func update_ammo_label():
	if $CanvasLayer.has_node("AmmoLabel"):
		var ammo_label = $CanvasLayer/AmmoLabel
		if reloading:
			ammo_label.text = "Bullets: 0 / %d" % max_shots
		else:
			ammo_label.text = "Bullets: %d / %d" % [max_shots - shots_fired, max_shots]

func show_you_win():
	win_shown = true  # Prevent multiple triggers

	if $CanvasLayer.has_node("ReloadingLabel"):
		var label = $CanvasLayer/ReloadingLabel
		label.visible = true
		label.text = "YOU WIN!"
		label.add_theme_color_override("font_color", Color(1, 1, 0))
		label.scale = Vector2(1.5, 1.5)

	await get_tree().create_timer(3.0).timeout

	# 🎉 Go back to main menu
	Global.score = 0
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
