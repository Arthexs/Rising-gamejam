extends BaseItem

func _ready() -> void:
	#super._ready()
	cost = 20
	text = "Regen  40%  (Cost:  20%)"

func effect() -> void:
	player.take_damage(-0.4*player.health_module.max_health)
	player.flash(Color.WEB_GREEN, 0.6, 0.4)
	remove_self()
