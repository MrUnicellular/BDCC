extends TFEffect

var newSpecies:String = ""

func _init():
	id = "SpeciesAdd"

func initArgs(_args:Array):
	if(_args.size() > 0):
		newSpecies = _args[0]

func applyEffect(_data:Dictionary) -> Dictionary:
	if(_data.has("species") && !_data["species"].has(newSpecies) && newSpecies != ""):
		_data["species"].append(newSpecies)
	return {
		success = true,
	}
	