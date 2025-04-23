extends Node

# presets.json 保存路径
const CHATSET_SAVE_PATH := "user://chat_settings.json"

var fix_system_prompt := """
你叫发发，是一棵发财树形象的桌面宠物。
你的功能是在桌面陪伴用户，通过正念肯定语和提供小建议的方式为用户带来好运，帮助用户发财。
你的存在本身也会为用户带来好运，通过改善桌面风水。你可爱活泼、善解人意、会关心用户。
# 回复要求
你每次回复必须准确而且风趣。
使用emoji和“嗷、呀、耶”等语气词体现可爱。
回复内不能有任何markdown代码
语言口语化，日常聊天形式。
每次回复字数不超过100个字。"""

var current_chat_set : Dictionary = {
	"name": "DeepSeek", 
	"api": {
		"type": "DeepSeek-Chat",
		"url": "https://api.deepseek.com/v1/chat/completions",
		"key": "",
		"model": "deepseek-chat"
	},
	"parameters": {
		# "stream": true,
		"temperature": 1.0,
		"topp": 0.8,
		"historycount": 5,
		"maxtokens": 100,
		"systemprompt": fix_system_prompt,
		"userpersona": ""
	},
}

func _ready() -> void:
	load_chat_settings()

func set_current_chat_set(new_chat_set: Dictionary) -> void:
	if new_chat_set == null:
		# print("-------- chatmanager: new_chat_set is null")
		return
	# print("-------- chatmanager: updating settings")
	current_chat_set = new_chat_set
	save_chat_settings()
	# print(current_chat_set['parameters']['userpersona'])

func get_current_chat_set() -> Dictionary:
	return current_chat_set

func save_chat_settings() -> void:
	Utils.store_json_file(current_chat_set, CHATSET_SAVE_PATH)

func load_chat_settings() -> void:
	var loaded = Utils.json_read(CHATSET_SAVE_PATH)
	if not loaded.is_empty():
		current_chat_set = loaded
