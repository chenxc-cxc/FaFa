extends Node
class_name TTSAPI

signal tts_completed
signal tts_failed(error_message: String)
signal tts_state_changed(state: String)  # 新增状态变化信号

@onready var http_request: HTTPRequest = $TTSHTTPRequest
@onready var audio_player: AudioStreamPlayer = $TTSAudioStreamPlayer

var is_playing: bool = false
var is_converting: bool = false
var current_text: String = ""

enum TTSState {READY, CONVERTING, PLAYING}

func _ready() -> void:
	pass


func play_tts(text: String) -> void:
	if text.is_empty():
		tts_failed.emit("Empty text provided")
		return
		
	if is_playing:
		audio_player.stop()
		
	current_text = text
	is_converting = true
	is_playing = false
	tts_state_changed.emit("CONVERTING")
	
	var tts_settings = TTSSetManager.get_current_tts_set()
	var url = tts_settings.api.url
	
	var headers = [
		"ai-api-key: " + tts_settings.api.key,
		"Content-Type: application/json"
	]
	# print(tts_settings.api.voiceid)
	
	var body = JSON.stringify({
		"text": current_text,
		"voice_id": tts_settings.api.voiceid,
		"model_id": tts_settings.api.modelid
		# "languagecode": tts_settings.parameters.languagecode,
		# "speed": tts_settings.parameters.speed
	})

	http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func stop_tts() -> void:
	if is_playing:
		audio_player.stop()
		is_playing = false
		is_converting = false
		tts_state_changed.emit("READY")

func _on_audio_stream_player_finished() -> void:
	is_playing = false
	is_converting = false
	tts_state_changed.emit("READY")
	tts_completed.emit()
	
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	is_converting = false
	
	if result != HTTPRequest.RESULT_SUCCESS:
		is_playing = false
		tts_failed.emit("TTS Failed: 网络请求失败，请检查网络连接。")
		tts_state_changed.emit("READY")
		return
	
	if response_code != 200:
		is_playing = false
		tts_failed.emit("TTS Failed: API返回错误，请检查API密钥是否正确。")
		tts_state_changed.emit("READY")
		return
		
	var stream = AudioStreamMP3.new()
	# todo：播放异常处理
	stream.data = body
	audio_player.stream = stream
	is_playing = true
	tts_state_changed.emit("PLAYING")
	audio_player.play()
