class_name APPacket extends Resource

@export var cmd: String

func _init(_cmd = "") -> void:
	cmd = _cmd
	
func from_dict(dict) -> void:
	for property in self.get_property_list():
		if (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) && (property.name in dict):
			set(property.name, dict[property.name])
	
func to_dict() -> Dictionary:
	var result = {}
	
	for property in self.get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var property_value = get(property.name)
			if property_value is APPacket:
				property_value = property_value.to_dict()
			result[property.name] = property_value
			
	if not self.cmd:
		result.erase("cmd")
			
	return result
	
func serialize() -> String:
	return "[" + JSON.stringify(self.to_dict()) + "]"
