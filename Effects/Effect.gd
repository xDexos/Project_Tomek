extends AnimatedSprite

func _ready() -> void:
	connect("animation_finished",self, "_on_AnimatedSprite_animation_finished")
	play("Animate")

func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
