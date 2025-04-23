class_name Utils

# json file read to dic
static func json_read(path:String) -> Dictionary:
	var file = FileAccess.open(path,FileAccess.READ)
	if file == null:
		# not this file.json
			return {}
	var content := JSON.parse_string(file.get_as_text()) as Dictionary
	file.close()
	return content

# store dict to json file
static func store_json_file(dic :Dictionary,path :String):
	var json := JSON.stringify(dic)
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(json)
	file.close()
