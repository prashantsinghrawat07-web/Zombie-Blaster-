extends Node2D

@onready var label := Label.new()

func _ready():
	# Create one label that will be reused
	label.text = "LEVEL 2"
	label.set("theme_override_colors/font_color", Color.WHITE)
	label.set("theme_override_font_sizes/font_size", 64)
	label.anchor_left = 0.5
	label.anchor_top = 0.5
	label.offset_left = -150
	label.offset_top = -40
	add_child(label)

	await get_tree().create_timer(2.0).timeout
	label.visible = false  # hide after showing "LEVEL 2"
	set_process(true)

	
