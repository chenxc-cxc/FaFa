extends Node2D


@export var color: Gradient
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var point_light_2d: PointLight2D = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 设置金币效果的参数
	cpu_particles_2d.color_ramp = color
	# 修改重力方向和大小，让金币更自然地下落
	cpu_particles_2d.gravity = Vector2(0, 200)
	# 减小初始速度，让金币看起来更像是撒落而不是爆炸
	cpu_particles_2d.initial_velocity_min = 30.0
	cpu_particles_2d.initial_velocity_max = 150.0
	# 减小扩散角度，让金币主要向下方散落
	cpu_particles_2d.spread = 120.0
	# 增加旋转，让金币看起来在空中翻转
	cpu_particles_2d.angle_min = -180
	cpu_particles_2d.angle_max = 180
	# 设置金币spritesheet动画
	cpu_particles_2d.anim_speed_min = 5.0
	cpu_particles_2d.anim_speed_max = 10.0
	# 确保每个金币从不同的帧开始动画
	cpu_particles_2d.anim_offset_min = 0.0
	cpu_particles_2d.anim_offset_max = 1.0
	# 开始发射粒子
	cpu_particles_2d.emitting = true
	# 播放音效
	audio_stream_player.play()
	# 创建金币闪光效果
	var tw = create_tween()
	tw.tween_property(point_light_2d,"energy",1,2.0).from(4)
	# 等待粒子效果完成后销毁节点
	await cpu_particles_2d.finished
	queue_free()
