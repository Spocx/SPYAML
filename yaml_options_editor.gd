extends PanelContainer
class_name YamlOptionsCreator

const RANGE_OPTION = preload("res://option_objects/range_option.tscn")
const TOGGLE_OPTION = preload("res://option_objects/toggle_option.tscn")
const CHOICE_OPTION = preload("res://option_objects/choice_option.tscn")
const LIST_OPTION = preload("res://option_objects/list_option.tscn")
const DICTIONARY_OPTION = preload("res://option_objects/dictionary_option.tscn")

@onready var sections_parent: VBoxContainer = $ScrollContainer/PanelContainer/sections
@onready var h_separator: HSeparator = $ScrollContainer/PanelContainer/sections/HSeparator

var sections : Dictionary[String,FoldableCustom]

const FOLDABLE_CUSTOM = preload("uid://w8748pip2m7w")

func createSections(section_array : Array[String]):
	for key in sections:
		sections[key].queue_free()
	
	sections.clear()
	
	for s in section_array:
		createSection(s)

func createSection(_name : String):
	var new_section : FoldableCustom = FOLDABLE_CUSTOM.instantiate()
	sections_parent.add_child(new_section)
	sections_parent.move_child(h_separator,sections_parent.get_child_count())
	sections[_name] = new_section
	new_section.set_title(_name) 

func createOptions(options_dict: Dictionary):
	for key in options_dict:
		if options_dict[key] is Dictionary:
			var type : OptionParent.TYPE = get_option_type(options_dict[key])
			var option : OptionParent
			match type:
				OptionParent.TYPE.TOGGLE:
					option = TOGGLE_OPTION.instantiate()
					pass
				OptionParent.TYPE.CHOICE:
					option = CHOICE_OPTION.instantiate()
					pass
				OptionParent.TYPE.RANGE:
					option = RANGE_OPTION.instantiate()
					pass
				OptionParent.TYPE.LIST:
					option = LIST_OPTION.instantiate()
					pass
				OptionParent.TYPE.DICTIONARY:
					option = DICTIONARY_OPTION.instantiate()
					pass
				OptionParent.TYPE.UNSUPORTED:
					pass
					
			if option != null:
				option.init(options_dict[key],key)
				addOptionToSection(option,options_dict[key]["section"])
				setOptionCommonValues(option,key)
			#print(key + " | " + options_dict[key]["section"] + " | " + OptionParent.TYPE.keys()[type])
	
	call_deferred("orderSectionOptions")
	call_deferred("section_option_labels_resize")
	call_deferred("openFirstSection")

func orderSectionOptions():
	for key in sections.keys():
		sections[key].reorder_children()

func section_option_labels_resize():
	#for key in sections.keys():
	#	sections[key].sizeLabels()
	
	var widest_label : float = 0
	var widest_value : float = 0
	var widest_edit : float = 0
	var widest_button : float = 0
	for key in sections.keys():
		widest_label = max(widest_label,sections[key].get_widest_label())
		widest_value = max(widest_value,sections[key].get_widest_value())
		widest_edit = max(widest_edit,sections[key].get_widest_edit())
		widest_button = max(widest_button,sections[key].get_widest_button())
		
	for key in sections.keys():
		sections[key].setSizes(widest_label,widest_value,widest_edit,widest_button)


func setOptionCommonValues(_option : OptionParent, _name):
	_option.set_option_name(_name)
	pass

func addOptionToSection(_option: OptionParent, _section: String):
	sections[_section].add_section_child(_option)
	pass

func get_option_type(option_data : Dictionary) -> OptionParent.TYPE:
	if option_data["value"].keys().size() == 1 and dict_has_values(option_data["value"],["list"]):
		return OptionParent.TYPE.LIST
		
	if option_data["value"].keys().size() == 1 and dict_has_values(option_data["value"],["dict"]):
		return OptionParent.TYPE.DICTIONARY
	
	if option_data["value"].keys().size() == 2 and dict_has_values(option_data["value"],["'true'","'false'"]):
		return OptionParent.TYPE.TOGGLE
	
	if option_data.has("description"):
		if description_contains_strings(option_data["description"],["You can define additional values between the minimum and maximum values.","Minimum value is","Maximum value is"]):
			return OptionParent.TYPE.RANGE
	
	var is_valid_choice_option = true
	var count_50 : int = 0
	for key in option_data["value"].keys():
		if option_data["value"][key] is not int:
			is_valid_choice_option = false
			break
		
		if option_data["value"][key] == 50:
			count_50 += 1
		pass
	if is_valid_choice_option and count_50 == 1:
		return OptionParent.TYPE.CHOICE
	
	return OptionParent.TYPE.DICTIONARY


func dict_has_values(dict : Dictionary, values: Array[String]) -> bool:
	for v in values:
		if !dict.has(v):
			return false
	return true
	
func description_contains_strings(description : String, values: Array[String]):
	for v in values:
		if !description.contains(v):
			return false
	return true

func openFirstSection():
	sections[sections.keys()[0]].fold()
	
