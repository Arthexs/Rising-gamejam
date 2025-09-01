extends BaseItem

func _ready() -> void:
	#super._ready()
	cost = 35
	text = "Gain  20%  Strength  (Cost:  35%)"

func effect() -> void:
	player.weapon.kp *= 1.2
	player.flash(Color.WEB_PURPLE, 0.6, 0.4)
	remove_self()
