extends BaseItem

func _ready() -> void:
	#super._ready()
	cost = 25
	text = "Gain  20%  Bigger Hammer  (Cost:  10%)"

func effect() -> void:
	#var holder: Node2D = player.weapon.get_parent() as Node2D
	player.weapon.collision_shape.scale *= 1.4
	player.weapon.sprite.scale *= 1.4
	player.weapon.mass *= 1.1
	player.flash(Color.WEB_PURPLE, 0.6, 0.4)
	remove_self()
