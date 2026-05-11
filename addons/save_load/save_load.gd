extends Node

var save_file_name = "Spocx_YAML_edit_"
	
##Global data can be used to save and load data globally. it's just a big dictionary
func saveData(data: SaveData, slot: int = 0):
	var save_file = FileAccess.open("user://"+str(save_file_name)+str(slot)+".save",FileAccess.WRITE)
	save_file.store_line(JSON.stringify(data.data,"\n"))
	pass

##will return GlobalData as a variable to read from and write to to save again. If no global save data exists it will return a new empty global save data to populate, which can then be used to save
func getSaveData(slot: int = 0) -> SaveData:
	if not getSaveDataExists(slot):
		return SaveData.new()
	var save_file = FileAccess.open("user://"+str(save_file_name)+str(slot)+".save", FileAccess.READ)
	var json_string = save_file.get_as_text()
	var json = JSON.new()
	var result = json.parse(json_string)
	var returndata : SaveData = SaveData.new()
	returndata.data = json.data
	save_file.close()
	return returndata
	pass

func getSaveDataExists(slot: int = 0) -> bool:
	return FileAccess.file_exists("user://"+str(save_file_name)+str(slot)+".save")
