extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 100
export var MAX_SPEED = 20
export var FRICTION = 30

enum {
	IDLE,
	WANDER,
	CHACE,
	ATTACK
}

var state = CHACE

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var stats = $Stats
onready var animationState = animationTree.get("parameters/playback")
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox

func _ready() -> void:
	animationTree.active = true
	
func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			idle_state(delta)
			
		WANDER:
			pass
			
		CHACE:
			chace_state(delta)

#		ATTACK:
#			attack_state()

			
func idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	animationState.travel("Idle")

func chace_state(delta):
	var player = playerDetectionZone.player
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		animationTree.set("parameters/Idle/blend_position", direction)
		animationTree.set("parameters/Walk/blend_position", direction)
		animationTree.set("parameters/Attack/blend_position", direction)
		animationState.travel("Walk")
	else:
		state = IDLE
	velocity = move_and_slide(velocity)
#
#func attack_state():
#	velocity = Vector2.ZERO
#	animationState.travel("Attack")
#


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHACE

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = area.knockback_vector * 40
	hurtbox.create_hit_effect()

func hit_animation_finished():
	state = CHACE

func _on_Stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
