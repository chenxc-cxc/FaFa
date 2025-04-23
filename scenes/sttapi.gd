extends Node
class_name STTAPI

signal recording_started
signal recording_stopped
signal stt_completed(text: String)
signal stt_failed(error: String)

var recording: AudioStreamWAV = null
var recording_effect: AudioEffectRecord
var recording_bus_idx: int
var is_recording: bool = false
var stt_settings: Dictionary

@onready var http_request: HTTPRequest = $STTHTTPRequest

func _ready() -> void:
	# 设置录音总线
	recording_bus_idx = AudioServer.get_bus_index("Record")
	if recording_bus_idx == -1:
		AudioServer.add_bus()
		recording_bus_idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(recording_bus_idx, "Record")
	
	# 添加录音效果器
	recording_effect = AudioEffectRecord.new()
	AudioServer.add_bus_effect(recording_bus_idx, recording_effect)
	
	# 连接HTTP请求完成信号
	http_request.request_completed.connect(_on_stt_request_completed)

func start_recording() -> void:
	if is_recording:
		return
		
	is_recording = true
	recording_effect.set_recording_active(true)
	recording_started.emit()

func stop_recording() -> void:
	if not is_recording:
		return
		
	is_recording = false
	recording_effect.set_recording_active(false)
	recording = recording_effect.get_recording()
	recording_stopped.emit()
	
	# 将录音发送到语音识别服务
	play_stt() 
	# 注释掉上一行，下一行注释取消，可以测试语音转文本后，文本提交是否正常
	# stt_completed.emit("也反对")

func play_stt() -> void:
	if not recording:
		stt_failed.emit("No recording available")
		return
	
	# 检查音频数据
	if recording.data.size() == 0:
		stt_failed.emit("Empty audio data")
		return
		
	# 检查音频格式
	if recording.format != AudioStreamWAV.FORMAT_16_BITS:
		stt_failed.emit("Unsupported audio format. Must be 16-bit WAV")
		return

	# print("Audio format: ", recording.mix_rate)
	if recording.mix_rate != 44100:
		stt_failed.emit("Unsupported sample rate. Must be 16kHz")
		return
		
	stt_settings = STTSetManager.get_current_stt_set() 
	var url = stt_settings.api.host + stt_settings.api.path
	var api_key = stt_settings.api.key
	var boundary = "boundary" + str(randi()) # 随机边界字符串

	# 构建multipart form-data
	var data = PackedByteArray()
	
	# 添加文件部分
	var file_header = String("--{boundary}\r\n").format({"boundary": boundary})
	file_header += "Content-Disposition: form-data; name=\"file\"; filename=\"audio.wav\"\r\n"
	file_header += "Content-Type: audio/wav\r\n\r\n"
	data.append_array(file_header.to_utf8_buffer())
	
	# 添加原始音频数据
	data.append_array(recording.data)
	data.append_array("\r\n".to_utf8_buffer())
	
	# 添加model参数
	var model_part = String("--{boundary}\r\n").format({"boundary": boundary})
	model_part += "Content-Disposition: form-data; name=\"model\"\r\n\r\n"
	model_part += stt_settings.api.model + "\r\n"
	data.append_array(model_part.to_utf8_buffer())
	
	# 添加language参数
	var lang_part = String("--{boundary}\r\n").format({"boundary": boundary})
	lang_part += "Content-Disposition: form-data; name=\"language\"\r\n\r\n"
	lang_part += stt_settings.api.language + "\r\n"
	data.append_array(lang_part.to_utf8_buffer())
	
	# 添加结束边界
	var end_boundary = String("--{boundary}--\r\n").format({"boundary": boundary})
	data.append_array(end_boundary.to_utf8_buffer())
	
	# 设置请求头
	var headers = [
		"Authorization: Bearer " + api_key,
		"Content-Type: multipart/form-data; boundary=" + boundary
	]
	
	# # 调试信息
	# print("Audio format: ", recording.format)
	# print("Sample rate: ", recording.mix_rate)
	# print("Channels: ", recording.stereo)
	# print("Audio data size: ", recording.data.size())
	# print("Request URL: ", url)
	# print("Headers: ", headers)
	
	# 发送请求
	var error = http_request.request_raw(url, headers, HTTPClient.METHOD_POST, data)
	if error != OK:
		stt_failed.emit("Failed to send request: " + str(error))

func _on_stt_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# print("Response code: ", response_code)
	# print("Response body: ", body.get_string_from_utf8())
	
	if result != HTTPRequest.RESULT_SUCCESS:
		stt_failed.emit("Request failed with result: " + str(result))
		return
		
	if response_code == 500:
		var error_msg = "Server error (500). "
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("error"):
			error_msg += json["error"]
		stt_failed.emit(error_msg)
		return
		
	if response_code != 200:
		var error_msg = "Server returned error: " + str(response_code)
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("error"):
			error_msg += " - " + json["error"]
		stt_failed.emit(error_msg)
		return
		
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		stt_failed.emit("Invalid response format")
		return
		
	if json.has("text"):
		stt_completed.emit(json["text"])
	else:
		stt_failed.emit("No text in response")
