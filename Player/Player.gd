extends KinematicBody2D

export var ACCELERATION = 1000
export var MAX_SPEED = 40
export var ROLL_SPEED = 100
export var FRICTION = 1000

enum {
	MOVE,
	HIT,
	ROLL
}
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/HammerHitbox
onready var hammerHitbox = $HitboxPivot/HammerHitbox
onready var hurtbox = $Hurtbox

func _ready() -> void:
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	hammerHitbox.knockback_vector = roll_vector

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state(delta)
			
		HIT:
			hit_state()
		
		ROLL:
			roll_state(delta)
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		hammerHitbox.knockback_vector = input_vector
		animationTree.set("parameters/idle/blend_position", input_vector)
		animationTree.set("parameters/run/blend_position", input_vector)
		animationTree.set("parameters/hit/blend_position", input_vector)
		animationState.travel("run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("ui_roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("ui_hit"):
		state = HIT

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	move()
	animationPlayer.play("roll")

func hit_state():
	velocity = Vector2.ZERO
	animationState.travel("hit")
	
func move():
	velocity = move_and_slide(velocity)
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE
	
func hit_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
