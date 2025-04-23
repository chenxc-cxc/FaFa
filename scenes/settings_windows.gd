extends Window

signal follow_mouse_changed(enabled: bool)
signal chat_setting_setting(enabled: bool)
signal tts_setting_setting(enabled: bool)

@onready var follow_mouse_check: CheckBox = %FollowMouseCheck
@onready var save_llm_setting_buttun: Button = %SaveLLMSettingButton
@onready var save_tts_setting_buttun: Button = %SaveTTSSetintButton

@onready var model_grid: GridContainer = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid

@onready var chat_model_name_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/NameLabel
@onready var chat_model_name: LineEdit = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/Name
@onready var type_label : Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/LLMFamilyLabel
@onready var type: OptionButton = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/LLMFamilyChoose
@onready var name_placeholder: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/NameErrorPlaceholder
@onready var name_error_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/NameNullLabel
@onready var option_placeholder: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/LLMFamilyErrorPlaceholder
@onready var option_error_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/LLMFamilyNullLabel

@onready var url_placeholder: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/URLErrorPlaceholder
@onready var url_error_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/URLNullLabel 
@onready var key_placeholder: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/KeyErrorPlaceholder
@onready var key_error_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/KeyNullLabel
@onready var model_placeholder: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/ModelErrorPlaceholder
@onready var model_error_label: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/ModelNullLabel
@onready var tts_grid: GridContainer = $MarginContainer/ScrollContainer/VBoxContainer/TTS/MarginContainer/VBoxContainer/TTSGrid

@onready var systempromptLabel: Label = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/SystemPromptLabel
@onready var systemprompt: TextEdit = $MarginContainer/ScrollContainer/VBoxContainer/Model/MarginContainer/VBoxContainer/ModelGrid/SystemPrompt


var chat_set = ChatSetManager.get_current_chat_set()
var tts_set = TTSSetManager.get_current_tts_set()

func _ready():
	follow_mouse_check.button_pressed = true # 默认开启跟随鼠标
	save_llm_setting_buttun.button_pressed = false # 默认button_pressed为false,只有在被点击时才为true，随后才会被重置为false
	save_tts_setting_buttun.button_pressed = false # 默认button_pressed为false,只有在被点击时才为true，随后才会被重置为false

	#初始化时隐藏占位符和错误提示
	name_placeholder.hide()
	name_error_label.hide()
	option_placeholder.hide()
	option_error_label.hide()
	url_placeholder.hide()
	url_error_label.hide()
	key_placeholder.hide()
	key_error_label.hide() 
	model_placeholder.hide()
	model_error_label.hide()

	# since we decide to build a special deskpet, wo decide to hide systempromptLabel and systemprompt
	systempromptLabel.hide()
	systemprompt.hide()

	# hide model options and self-define name
	chat_model_name_label.hide()
	chat_model_name.hide()
	type_label.hide()
	type.hide()

	# 加载并显示LLM配置
	var chat_config = ChatSetManager.get_current_chat_set()
	if not chat_config.is_empty():
		for child in model_grid.get_children():
			if child is LineEdit or child is TextEdit:
				var little_name = child.name.to_lower()
				child.text = chat_set["api"].get(little_name, "")
				match little_name:
					# "name":
					# 	child.text = chat_config["api"].get("name", "")
					# "type":
					# 	child.text = chat_config["api"].get("type", "")
					"url":
						child.text = chat_config["api"].get("url", "https://api.deepseek.com/v1/chat/completions")
					"key":
						child.text = chat_config["api"].get("key", "sk-5ebebc37284e445598ae9c3080afd3ff")
					"model":
						child.text = chat_config["api"].get("model", "deepseek-chat")
					"historycount":
						child.text = str(chat_config["parameters"].get("historycount", 5))
					"topp":
						child.text = str(chat_config["parameters"].get("topp", 0.8))
					"temperature":
						child.text = str(chat_config["parameters"].get("temperature", 1.0))
					"maxtokens":
						child.text = str(chat_config["parameters"].get("maxtokens", 100))
					"systemprompt":
						child.text = ChatSetManager.fix_system_prompt # fix system prompt
					"userpersona":
						child.text = chat_config["parameters"].get("userpersona", "")

	# 加载并显示TTS配置
	var tts_config = TTSSetManager.get_current_tts_set()
	if not tts_config.is_empty():
		for child in tts_grid.get_children():
			if child is LineEdit or child is TextEdit:
				var little_name = child.name.to_lower()
				match little_name:
					"type":
						child.text = tts_config["api"].get("type", "AllVoiceLab")
					"ttsurl":
						child.text = tts_config["api"].get("url", "https://api.allvoicelab.cn/v1/text-to-speech/create")
					"key":
						child.text = tts_config["api"].get("key", "ak_d2dd32f22f82d843170b2a5204c1d862dda2")
					"voiceid":
						child.text = tts_config["api"].get("voiceid", "272878038100738056")
					"modelid":
						child.text = tts_config["api"].get("modelid", "tts-multilingual")
					"languagecode":
						child.text = tts_config["api"].get("languagecode", "zh")
					"speed":
						child.text = str(tts_config["parameters"].get("speed", 1.0))

	# # 加载并显示STT配置
	# var stt_config = STTSetManager.get_current_stt_set()
	# if not stt_config.is_empty():
	# 	for child in stt_grid.get_children():
	# 		if child is LineEdit:
	# 			var little_name = child.name.to_lower()
	# 			match little_name:
	# 				"type":
	# 					child.text = stt_config["api"].get("type", "")
	# 				"host":
	# 					child.text = stt_config["api"].get("host", "")
	# 				"path":
	# 					child.text = stt_config["api"].get("path", "")
	# 				"key":
	# 					child.text = stt_config["api"].get("key", "")
	# 				"model":
	# 					child.text = stt_config["api"].get("model", "")
	# 				"language":
	# 					child.text = stt_config["api"].get("language", "")


func _on_close_requested():
	hide()

func _on_follow_mouse_check_toggled(button_pressed):
	emit_signal("follow_mouse_changed", button_pressed)


func validate_user_new_chatset_dic() -> bool:
	chat_set["api"]["name"] = "test"
	chat_set["api"]["type"] = "test"
	for child in model_grid.get_children():
		if child is LineEdit or child is TextEdit:
			var little_name := child.name.to_lower()
			match little_name:
				"url": 
					if child.text == "":
						url_error_label.text = "Please enter your Model URL,\neg. https://api.deepseek.com/v1/chat/completions"
						url_placeholder.show()
						url_error_label.show()
						return false
					else:
						url_placeholder.hide()
						url_error_label.hide()
					chat_set["api"]["url"] = child.text
				"key": 
					if child.text == "":
						key_error_label.text = "Please enter your API key. eg. sk-xxxxxxxxxxxxxxxxxxxxxxxxx"
						key_placeholder.show()
						key_error_label.show()
						return false
					else:
						key_placeholder.hide()
						key_error_label.hide()
					chat_set["api"]["key"] = child.text
				"model": 
					if child.text == "":
						model_error_label.text = "Please enter your Model choice. eg. deepseek-chat"
						model_placeholder.show()
						model_error_label.show()
						return false
					else:
						model_placeholder.hide()
						model_error_label.hide()
					chat_set["api"]["model"] = child.text

				"historycount": 
					if not child.text.is_valid_int() or child.text.to_int() < 0:
						child.text = "5"  # 无效整数，设置默认值
					chat_set["parameters"]["historycount"] = child.text.to_int()
				"topp":  
					if not child.text.is_valid_float() or child.text.to_float() < 0 or child.text.to_float() > 1:
						child.text = "0.8"  # 无效浮点数，设置默认值
					chat_set["parameters"]["topp"] = child.text.to_float()

				"temperature": 
					if not child.text.is_valid_float() or child.text.to_float() < 0 or child.text.to_float() > 1:
						child.text = "1.0"  # 无效浮点数，设置默认值
					chat_set["parameters"]["temperature"] = child.text.to_float()
				"maxtokens": 
					if not child.text.is_valid_int() or child.text.to_int() < 0:
						child.text = "100"  # 无效整数，设置默认值
					chat_set["parameters"]["maxtokens"] = child.text.to_int()
				# "systemprompt": 
				# 	if child.text.strip_edges().is_empty():
				# 		child.text = "You are a helpful assistant."
				# 	chat_set["parameters"]["systemprompt"] = child.text
				"userpersona": 
					chat_set["parameters"]["userpersona"] = child.text
	return true

func validate_user_new_tts_dic() -> bool:
	for child in tts_grid.get_children():
		if child is LineEdit or child is TextEdit:
			var little_name := child.name.to_lower()
			match little_name:
				"type":
					if child.text.is_empty():
						tts_set["api"]["type"] = "AllVoiceLab"
					else:
						tts_set["api"]["type"] = child.text
				"ttsurl":
					if child.text.is_empty():
						return false
					tts_set["api"]["url"] = child.text
				"key":
					if child.text.is_empty():
						return false
					tts_set["api"]["key"] = child.text
				"voiceid":
					if child.text.is_empty():
						return false
					tts_set["api"]["voiceid"] = child.text
				"modelid":
					if child.text.is_empty():
						return false
					tts_set["api"]["modelid"] = child.text
				"languagecode":
					if child.text.is_empty():
						child.text = "zh"
					if child.text not in ["zh", "en", "ja", "ko", "fr", "de"]:
						return false
					tts_set["api"]["languagecode"] = child.text
				"speed":
					if not child.text.is_valid_float() or child.text.to_float() < 0.5 or child.text.to_float() > 1.5:
						child.text = "1.0"  # 无效浮点数，设置默认值
					tts_set["parameters"]["speed"] = child.text.to_float()
	return true

# func _on_llm_family_choose_item_selected(index: int) -> void:
# 	# todo:是用来做添加一个选项变化的时候所有文本框的默认内容都会变化的功能
# 	pass # Replace with function body.

func _on_save_llm_setting_button_pressed() -> void:
	emit_signal("chat_setting_setting", true)
	var if_update_succ = validate_user_new_chatset_dic()
	if if_update_succ:
		# print("update_llm_setting_validate success")
		var new_chat_set = chat_set
		ChatSetManager.set_current_chat_set(new_chat_set)  # 自动触发保存
	emit_signal("chat_setting_setting", false)

func _on_save_tts_setting_button_pressed() -> void:
	emit_signal("tts_setting_setting", true)
	var if_update_succ = validate_user_new_tts_dic()
	if if_update_succ:
		# print("update_tts_setting_validate success")
		var new_tts_set = tts_set
		TTSSetManager.set_current_tts_set(new_tts_set)  # 自动触发保存
	emit_signal("tts_setting_setting", false)

func _on_save_stt_setting_button_pressed() -> void:
	pass
	#emit_signal("stt_setting_setting", true)
	#var if_update_succ = validate_user_new_stt_dic()
	#if if_update_succ:
		#print("update_stt_setting_validate success")
		#var new_stt_set = stt_set
		#STTSetManager.set_current_stt_set(new_stt_set)  # 这会自动触发保存
	#emit_signal("stt_setting_setting", false)
