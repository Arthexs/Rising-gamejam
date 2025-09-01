extends BaseItem

func _ready() -> void:
	#super._ready()
	cost = 20
	text = "Gain  25%  max health  (Cost:  20%)"

func effect() -> void:
	player.health_module.max_health *= 1.25
	player.flash(Color.DARK_GREEN, 0.6, 0.4)
	remove_self()
