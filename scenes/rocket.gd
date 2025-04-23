extends RigidBody2D

@export var color: Gradient
@export var firework_scene: PackedScene
@export var min_height: float = 300.0  # 最小高度
@export var initial_impulse: float = 1200.0  # 可配置的初始冲量
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var start_position: float = global_position.y  # 记录初始位置

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 使用配置的初始冲量
	apply_central_impulse(Vector2(0, -initial_impulse))
	audio_stream_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 检查是否达到最小高度且速度接近零
	var current_height = start_position - global_position.y
	if current_height >= min_height and linear_velocity.y >= -50:
		var firework = firework_scene.instantiate()
		firework.global_position = global_position
		firework.color = color
		get_parent().add_child(firework)
		queue_free()
	
	# 添加安全检查，如果火箭开始下落且低于最小高度，强制触发
	elif current_height < min_height and linear_velocity.y > 0:
		var firework = firework_scene.instantiate()
		firework.global_position = global_position
		firework.color = color
		get_parent().add_child(firework)
		queue_free()
