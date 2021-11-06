extends Node2D

export (String) var hanzi
var move_tween
var matched = false

func _ready():
	move_tween = $MoveTween

func move(target):
	$MoveTween.interpolate_property(self, "position", position, target, .3, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$MoveTween.start()

func set_hanzi(new_hanzi):
	hanzi = new_hanzi
	$Label.text = new_hanzi

func get_hanzi():
	return hanzi


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func dim():
	$Sprite.modulate = Color(1,1,1,.1)
	pass
