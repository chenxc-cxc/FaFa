extends Node

const TTSSET_SAVE_PATH := "user://tts_settings.json"

var current_tts_set: Dictionary = {
	"name": "AllVoiceLab",
	"api": {
		"type": "AllVoiceLab",
		"url": "https://api.allvoicelab.cn/v1/text-to-speech/create",
		"key": "",
		"voiceid": "280798412406784140",
		"modelid": "tts-multilingual"
	},
	"parameters": {
		"languagecode": "zh",
		"speed": 1.0,

	}
}

func _ready() -> void:
	load_tts_settings()

func set_current_tts_set(new_tts_set: Dictionary) -> void:
	if new_tts_set == null:
		# print("-------- ttsmanager: new_tts_set is null")
		return
	# print("-------- ttsmanager: updating settings")
	current_tts_set = new_tts_set
	save_tts_settings()

func get_current_tts_set() -> Dictionary:
	return current_tts_set

func save_tts_settings() -> void:
	Utils.store_json_file(current_tts_set, TTSSET_SAVE_PATH)

func load_tts_settings() -> void:
	var loaded = Utils.json_read(TTSSET_SAVE_PATH)
	if not loaded.is_empty():
		current_tts_set = loaded
