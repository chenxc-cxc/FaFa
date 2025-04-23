extends Node2D

@onready var polygon_2d_player: Polygon2D = $Player/Polygon2DPlayer
@onready var polygon_2d_menu: Polygon2D = $Player/Polygon2DMenu
@onready var area_2d: Area2D = $Player/Sprite2D/Area2D
@onready var llmapi: AI = $LLMAPI
@onready var player: Node2D = $Player
@onready var control: Control = $Player/Control
@onready var rich_text_label: RichTextLabel = $Player/Control/PanelContainer/MarginContainer/VBoxContainer/RichTextLabel
@onready var line_edit: LineEdit = $Player/Control/PanelContainer/MarginContainer/VBoxContainer/InputContainer/LineEdit
@onready var animation_player: AnimationPlayer = $Player/AnimationPlayer
@onready var sprite_2d: Sprite2D = $Player/Sprite2D
@onready var ttsapi: TTSAPI = $TTSAPI
@onready var tts_button: Button = $Player/Control/PanelContainer/MarginContainer/VBoxContainer/TTSGridContainer/TTSButton
@onready var tts_error_label: Label = $Player/Control/PanelContainer/MarginContainer/VBoxContainer/TTSErrorLabel
@onready var tts_grid_container: GridContainer = $Player/Control/PanelContainer/MarginContainer/VBoxContainer/TTSGridContainer
@onready var home_window: Window = $HomeWindow
@onready var fire_window: Window = $FireWindow
@onready var settings_window: Window = $SettingsWindow
@onready var voice_input_button: Button = $Player/Control/PanelContainer/MarginContainer/VBoxContainer/InputContainer/VoiceInputButton
@onready var sttapi: STTAPI = $STTAPI

var main_window: Window 
var screen: int
var show_menu:bool = false
var dragging:bool = false
var mouse_pos :Vector2i
var polygon : Polygon2D
var polygons = []
var direction = Vector2i.RIGHT
var current_state = "idle"
var if_chat_end: bool = true
var latest_follow_mouse_state: bool = true
var last_settings_position: Vector2i  # 新增变量来存储设置窗口上一次位置
var current_response: String = ""

enum QuickChatType {QUICKCHAT1, QUICKCHAT2, QUICKCHAT3}
# todo： change quickchat query
var quick_chat_messages = {
	QuickChatType.QUICKCHAT1: "", # 因为godot 的原因，无法在此处获取，只能在每次调用时进行实时嵌入
	# QuickChatType.QUICKCHAT1: "今天是%s，请给我今日穿搭幸运色以及配饰建议" % Time.get_date_string_with_format("yyyy年MM月dd日"),
	QuickChatType.QUICKCHAT2: "", # 因为godot 的原因，无法在此处获取，只能在每次调用时进行实时嵌入
	# 	QuickChatType.QUICKCHAT2: "”“今天是date，请给我一条适用于年轻人的养生建议。
# 你可以从：早睡、运动、饮料、食物、情绪管理、提肛、喝水、时令等多方向中进行建议“”“,
	QuickChatType.QUICKCHAT3: """用一句话反焦虑，安抚我，夸夸我，给我力量(30字以内)。
类似：
不需要提前焦虑，也不要预知烦恼哦，生活就是见招拆招。
你有力量度过任何难关
你是最好的！你值得任何美好的东西！""",
}

enum COMMAND {REST, RESULT_SUCCESS, MONEY, GAME, TASK,HELP}
var command_dict = {"rest": COMMAND.REST,
					"money":COMMAND.MONEY,
					"game":COMMAND.GAME,
					"task":COMMAND.TASK,
					"help": COMMAND.HELP}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_window()
	control.scale = Vector2.ZERO
	polygons = [polygon_2d_player, polygon_2d_menu]
	polygon = polygons[int(show_menu)]	
	line_edit.text_submitted.connect(on_submitted)
	llmapi.chat_request_started.connect(on_chat_request_started)
	llmapi.chat_request_finished.connect(on_chat_request_finished)
	area_2d.input_event.connect(on_input_event)

	settings_window.follow_mouse_changed.connect(_on_follow_mouse_changed)

	# 添加TTS相关信号连接
	tts_button.pressed.connect(_on_tts_button_pressed)
	ttsapi.tts_completed.connect(on_tts_completed)
	ttsapi.tts_failed.connect(on_tts_failed)
	ttsapi.tts_state_changed.connect(_on_tts_state_changed)
	#tts_button.hide()
	tts_grid_container.hide()
	tts_error_label.hide()  # 确保错误标签初始时隐藏
	
	# settings_window.chat_setting_setting.connect(on_chat_setting_changed)
	#llm_api_config_line_edit.text_submitted.connect(_on_llm_api_config_submitted)  # 连接LLM API配置LineEdit的text_submitted信号

	# 添加语音输入相关信号连接
	voice_input_button.pressed.connect(_on_voice_input_button_pressed)
	sttapi.stt_completed.connect(_on_stt_completed)
	sttapi.stt_failed.connect(_on_stt_failed)
	sttapi.recording_started.connect(_on_recording_started)
	sttapi.recording_stopped.connect(_on_recording_stopped)

	# stt not supported yet
	voice_input_button.hide()

	# 连接快速聊天按钮信号
	var quick_chat_buttons = {
		$Player/Control/PanelContainer/MarginContainer/VBoxContainer/TTSGridContainer/QuickChat1: QuickChatType.QUICKCHAT1,
		$Player/Control/PanelContainer/MarginContainer/VBoxContainer/TTSGridContainer/QuickChat2: QuickChatType.QUICKCHAT2,
		$Player/Control/PanelContainer/MarginContainer/VBoxContainer/TTSGridContainer/QuickChat3: QuickChatType.QUICKCHAT3,
	}
	
	for button in quick_chat_buttons:
		button.pressed.connect(_on_quick_chat_button_pressed.bind(quick_chat_buttons[button]))

	# # 使聊天回复可复制
	# rich_text_label.selection_enabled = true
	# rich_text_label.context_menu_enabled = true  # 启用右键菜单
	
	# # 设置输入框光标

	# line_edit.selecting_enabled = true  # 允许文本选择
	# line_edit.context_menu_enabled = true  # 启用右键菜单

func _physics_process(delta: float) -> void:
	update_click_through()
	# move()
	if if_chat_end and latest_follow_mouse_state and not dragging:
		move()
	
func get_direction():
	var target_pos = DisplayServer.mouse_get_position()
	var current_pos = main_window.position + Vector2i(310, 382)
	var distance = target_pos - current_pos

	if distance.length() < 150: 
		current_state = "idle"
	else:
		current_state = "walk"
		direction = Vector2i.RIGHT if distance.x >0 else Vector2i.LEFT
	
func move():
	get_direction()
	animation_player.play(current_state)
	sprite_2d.flip_h = direction == Vector2i.LEFT
	if current_state == "walk":
		var target_pos = DisplayServer.mouse_get_position()
		var current_pos = main_window.position + Vector2i(310, 382)
		var move_speed = 5
		var move_dir = (Vector2(target_pos - current_pos)).normalized()
		main_window.position += Vector2i(move_dir * move_speed)
		

func setup_window():
	main_window = get_window()
	main_window.size = DisplayServer.screen_get_size()
	screen = DisplayServer.window_get_current_screen(main_window.get_window_id())


func update_click_through():
	var click_polygon: PackedVector2Array = polygon.polygon
	for vec_i in range(click_polygon.size()):
		click_polygon[vec_i] = polygon.to_global(click_polygon[vec_i])
	#window.mouse_passthrough_polygon = click_polygon
	DisplayServer.window_set_mouse_passthrough(click_polygon)	

func _input(event):
	if event.is_action_pressed("drag") and  not dragging:
		dragging = true	
		mouse_pos = get_global_mouse_position()

	elif event.is_action_released("drag") and dragging:
		dragging = false

	elif event.is_action_pressed("right_click"):
		if settings_window.is_visible():
			# save last position
			last_settings_position = settings_window.position 
			# Godot 的 Window 节点在关闭时会触发 hide()，但不会销毁窗口。
			settings_window.hide()
		else:
			# settings_window.position = DisplayServer.mouse_get_position()
			# settings_window.position = last_settings_position
			settings_window.show()
			# settings_window.grab_focus()  # 使窗口刚打开时获得焦点，测试之后觉得不设置更好

	if event is InputEventMouseMotion and dragging:
		DisplayServer.window_set_position(DisplayServer.mouse_get_position()-mouse_pos)
		
	if event.is_action_pressed("quit"):
		get_tree().quit()
		

func show_sprite():
	sprite_2d.show()
	
func hide_sprite():
	show_menu = false
	control.scale = Vector2.ZERO
	sprite_2d.hide()
	
	# 隐藏所有按钮
	for child in tts_grid_container.get_children():
		if child is Button:
			child.hide()

func show_text(text: String, time: float):
	# 在开始显示新文本时，先关闭TTS相关控件
	tts_button.hide()
	tts_grid_container.hide()
	tts_error_label.hide()
	
	rich_text_label.text = text

	# 动画显示文本
	var tw = create_tween()
	tw.tween_property(rich_text_label, "visible_ratio", 1, time).from(0)
	await tw.finished
	
	current_response = text  # 保存当前回复用于TTS
	# tts_button.text = "语音播放"
	tts_button.show()
	tts_grid_container.show()
	tts_button.disabled = false

	# 在显示TTS按钮的同时显示快速聊天按钮
	for child in tts_grid_container.get_children():
		if child is Button:
			child.show()
			child.disabled = false

func _on_tts_button_pressed() -> void:
	if current_response.is_empty():
		return
	tts_button.disabled = true
	ttsapi.play_tts(current_response)

func on_tts_completed() -> void:
	tts_button.disabled = false
	tts_error_label.hide()  # TTS成功完成时隐藏错误标签

func on_tts_failed(error_message: String) -> void:
	tts_button.disabled = false
	tts_error_label.text = error_message  # 设置错误信息
	tts_error_label.show()  # 只在失败时显示错误标签

func on_input_event(viewport, event,shapeidx):
	if event.is_action_released("click"):
		show_menu = not show_menu
		
		var tw = create_tween()
		if show_menu:
			# 禁用跟随
			if_chat_end = false
			current_state = "idle"
			animation_player.play(current_state)

			polygon = polygons[int(show_menu)]
			tw.tween_property(control,"scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
			await tw.finished
			show_text("钱来~钱来~钱从四面八方来！\n输入#+空格+help可以显示特殊指令帮助哦，按下Esc退出！",1)
		else:
			# 关闭菜单时隐藏TTS相关控件
			tts_button.hide()
			tts_grid_container.hide()
			tw.tween_property(control,"scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
			rich_text_label.visible_ratio=0
			await tw.finished
			polygon = polygons[int(show_menu)]

			# # 恢复成最新的跟随状态
			if_chat_end = true
			if latest_follow_mouse_state:
				current_state = "walk"
			else:
				current_state = 'idle'
			animation_player.play(current_state)


func check_command(text):
	match command_dict[text]:
		COMMAND.MONEY:
			show_text("发大财", 1)
			await get_tree().create_timer(1).timeout
			hide_sprite()
			fire_window.start()
		COMMAND.REST:
			show_text("休息休息眼睛吧，看看天上有没有流星", 1)
			await get_tree().create_timer(1).timeout
			hide_sprite()
			home_window.start(main_window.position)
		COMMAND.HELP:
			show_text("""Option+Control可唤起设置界面,可自定义API配置。\n快速聊天按键说明:\n\t按键1, 提供穿搭建议\n\t按键2, 提供养生建议\n\t按键3, 正能量夸夸\n
特殊指令:\n\t# rest: 休息\n\t# money: 撒金币\n""", 1)


func on_submitted(new_text:String):
	if new_text.strip_edges().is_empty():
		return
	line_edit.clear() # cxc: clear sendbox

	if new_text.begins_with("#"):
		var command_array = new_text.split(" ")
		if 	command_dict.has(command_array[1]):
			check_command(command_array[1])
	else:
		llmapi.call_ai_chat(new_text)
		# show_text("让我想想让我想想让我想想让我想想让我想想让\n让我想想让我想想让我想想让我想想让我想想让\n让我想想让我想想让我想想让我想想让我想想让\n让我想想让我想想让我想想让我想想让我想想让\n让我想想让我想想让我想想让我想想让我想想让\n让我想想让我想想让我想想让我想想让我想想让\n我想想让我想想让我想想让我想想让我想想\n让我想想让我想想让我想想让我想想让我想想让我想想让我想想",1)
	
func on_chat_request_started() -> void:
	rich_text_label.modulate = Color(0.2, 0.2, 0.2, 1)  # 设置浅灰色
	show_text("让发发想想...", 1)

func on_chat_request_finished(output: String) -> void:
	rich_text_label.modulate = Color.WHITE  # 恢复正常颜色
	show_text(output, 1)

func _on_follow_mouse_changed(enabled: bool):
	latest_follow_mouse_state = enabled
	if not enabled or show_menu:
		current_state = "idle"
		animation_player.play(current_state)

func _on_voice_input_button_pressed() -> void:
	if not sttapi.is_recording:
		sttapi.start_recording()
	else:
		sttapi.stop_recording()

func _on_recording_started() -> void:
	voice_input_button.modulate = Color.RED  # 录音时按钮变红
	line_edit.placeholder_text = "正在录音..."

func _on_recording_stopped() -> void:
	voice_input_button.modulate = Color.WHITE  # 恢复按钮颜色
	line_edit.placeholder_text = "正在识别..."

func _on_stt_completed(text: String) -> void:
	line_edit.text = text
	line_edit.placeholder_text = line_edit.text
	# 发送识别的文本
	on_submitted(text)

func _on_stt_failed(error: String) -> void:
	line_edit.placeholder_text = "语音识别失败: " + error

func _on_tts_state_changed(state: String) -> void:
	match state:
		"CONVERTING":
			tts_button.text = "转换中"
		"PLAYING":
			tts_button.text = "播放中"
		"READY":
			tts_button.text = "语音播放"

func _on_quick_chat_button_pressed(chat_type: QuickChatType) -> void:
	var message = ""
	if quick_chat_messages.has(chat_type):
		if chat_type == QuickChatType.QUICKCHAT1:
			var datetime = Time.get_datetime_dict_from_system()
			message= "今天是%d年%02d月%02d日，请给我今日穿搭幸运色以及配饰建议" % [
				datetime.year, datetime.month, datetime.day]
		elif chat_type == QuickChatType.QUICKCHAT2:
			var datetime = Time.get_datetime_dict_from_system()
			message = "今天是%d年%02d月%02d日，请给我一条适用于年轻人的养生建议。\n你可以从：早睡、运动、饮料、食物、情绪管理、提肛、喝水、时令等多方向中进行建议" % [
				datetime.year, datetime.month, datetime.day]
		else:
			message = quick_chat_messages[chat_type]
		# print(message)
		on_submitted(message)
