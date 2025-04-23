# # 存储Chat API相关配置
# class_name PresetClass

# class APIConfig:
# 	var host: String
# 	var key: String
# 	var model: String
# 	var path: String
# 	var llmfamily: String
	
# 	func _init(m_host := "", m_key := "", m_model := "", m_path := "", m_llmfamily := "") -> void:
# 		host = m_host
# 		key = m_key
# 		model = m_model
# 		path = m_path
# 		llmfamily = m_llmfamily
	
# 	func to_dict() -> Dictionary:
# 		return {
# 			"host": host,
# 			"key": key,
# 			"model": model,
# 			"path": path,
# 			"llmfamily": llmfamily
# 		}

# class Parameters:
# 	var historycount: int
# 	var maxtokens: int
# 	# var stream: bool
# 	var systemprompt: String
# 	var temperature: float
# 	var topp: float
	
# 	func _init(
#         m_historycount := 5, 
#         m_maxtokens := 3000, 
#         # m_stream := true,
#         m_systemprompt := "", 
#         m_temperature := 1.0, 
#         m_topp := 0.3
#     ) -> void:
# 		historycount = m_historycount
# 		maxtokens = m_maxtokens
# 		# stream = m_stream
# 		systemprompt = m_systemprompt
# 		temperature = m_temperature
# 		topp = m_topp
	
# 	func to_dict() -> Dictionary:
# 		return {
# 			"historycount": historycount,
# 			"maxtokens": maxtokens,
# 			# "stream": stream,
# 			"systemprompt": systemprompt,
# 			"temperature": temperature,
# 			"topp": topp
# 		}

# class Preset:
# 	var name: String
# 	var api: APIConfig
# 	var parameters: Parameters
	
# 	func _init(m_name := "", m_api := APIConfig.new(), m_parameters := Parameters.new()) -> void:
# 		name = m_name
# 		api = m_api
# 		parameters = m_parameters
	
# 	func to_dict() -> Dictionary:
# 		return {
# 			"name": name,
# 			"api": api.to_dict(),
# 			"parameters": parameters.to_dict()
# 		}
