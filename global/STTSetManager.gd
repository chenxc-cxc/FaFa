extends Node

const STTSET_SAVE_PATH := "user://stt_settings.json"

var current_stt_set: Dictionary = {
	"name": "Coze STT",
	"api": {
		"type": "Coze-STT",
		"host": "https://api.coze.cn",
		"path": "/v1/audio/transcriptions",
		"key": "",
		"model": "whisper-1",
		"language": "zh"
	}, 
	"parameters": {
		"format": "wav",
		"sample_rate": 16000
	}
}

func _ready() -> void:
	load_stt_settings()

func set_current_stt_set(new_stt_set: Dictionary) -> void:
	if new_stt_set == null:
		# print("-------- sttmanager: new_stt_set is null")
		return
	# print("-------- sttmanager: updating settings")
	current_stt_set = new_stt_set
	save_stt_settings()

func get_current_stt_set() -> Dictionary:
	return current_stt_set

func save_stt_settings() -> void:
	Utils.store_json_file(current_stt_set, STTSET_SAVE_PATH)

func load_stt_settings() -> void:
	var loaded = Utils.json_read(STTSET_SAVE_PATH)
	if not loaded.is_empty():
		current_stt_set = loaded
