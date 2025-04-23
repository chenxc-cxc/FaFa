extends Node
class_name AI

signal chat_request_finished
signal chat_request_started  # 新增信号

@onready var http_request: HTTPRequest = $HTTPRequest

var output: String
var history: Array
# var history_count: int = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http_request.request_completed.connect(on_chat_http_request_completed)

func get_current_chat_set():
	var new_chat_set = ChatSetManager.get_current_chat_set()
	return new_chat_set

func call_ai_chat(prompt: String) -> void:
	# 在发送请求前发出信号
	chat_request_started.emit()
	
	var chatsettings = get_current_chat_set()
	var total_system_prompt = chatsettings.parameters.systemprompt + "\n我是一个这样的人：" + chatsettings.parameters.userpersona
	# print(total_system_prompt)
	# print(prompt)

	var new_message = {"role": "user", "content": prompt}
	var sys_message = {"role": "system", "content": total_system_prompt}
	var messages = [sys_message]

	history.append(new_message)
	messages.append_array(history.slice(-chatsettings.parameters.historycount))
	
	var headers = [
		"Authorization: Bearer " + chatsettings.api.key,
		"Content-Type: application/json"
	]
	
	var body = JSON.stringify({
		"model": "deepseek-chat",
		"messages": messages,
		"temperature": chatsettings.parameters.temperature,
		"max_tokens": chatsettings.parameters.maxtokens ,
		"top_p": chatsettings.parameters.topp,
		# "frequency_penalty": 0,
		# "presence_penalty": 0
	})
	
	var url = chatsettings.api.url
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)


func on_chat_http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		output = "网络请求失败，请检查网络连接。"
		chat_request_finished.emit(output)
		return
		
	if response_code != 200:
		output = "API返回错误，请检查API密钥是否正确。"
		chat_request_finished.emit(output)
		return
		
	var response = JSON.parse_string(body.get_string_from_utf8())

	if response == null:
		output = "返回数据解析失败。"
		chat_request_finished.emit(output)
		return
		
	# 根据不同API返回格式处理响应
	if response.has("choices"):
		if response.choices[0].has("message"):
			# ChatGPT API 格式
			output = response.choices[0].message.content
		else:
			# 其他API格式
			output = response.choices[0].message.content
			
	history.append({"role": "assistant", "content": output})
	chat_request_finished.emit(output)

# # todo：添加一个清理历史记录的 butttun
# func clear_history() -> void:
# 	history.clear()
