extends CodeContex
class_name DatapackSceneCodeContext

var scene:SceneBase
var datapackScene:DatapackScene
var datapack:Datapack

var buttons = {}
var curButtonIndex = 0

var storedErrors = []

func setDatapackScene(theScene):
	datapackScene = theScene

func setDatapack(theDatapack):
	datapack = theDatapack

func setScene(theScene):
	scene = theScene

func say(text):
	scene.say(processOutputString(text))

func sayn(text):
	scene.sayn(processOutputString(text))

func saynn(text):
	scene.saynn(processOutputString(text))

func getFlag(theVar:String, defaultValue = null, _codeblock = null):
	if(GM.main == null):
		return .getFlag(theVar, defaultValue, _codeblock)
	
	if(datapack.flags.has(theVar)):
		return GM.main.getDatapackFlag(datapack.id, theVar, defaultValue)
	
	return GM.main.getFlag(theVar, defaultValue)

func setFlag(theVar:String, newValue, _codeblock):
	if(GM.main == null):
		return .setFlag(theVar, newValue, _codeblock)
	
	if(datapack.flags.has(theVar)):
		var varType = datapack.flags[theVar]["type"]
		
		if(varType == DatapackSceneVarType.BOOL && !(newValue is bool)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a BOOLEAN flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.STRING && !(newValue is String)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a STRING flag "+str(theVar))
			return
		if(varType == DatapackSceneVarType.NUMBER && !(newValue is int) && !(newValue is float)):
			throwError(_codeblock, "Trying to assign a '"+str(newValue)+"' value to a NUMBER flag "+str(theVar))
			return
		GM.main.setDatapackFlag(datapack.id, theVar, newValue)
		return
	GM.main.setFlag(theVar, newValue)

func throwError(_codeBlock, _errorText):
	.throwError(_codeBlock, _errorText)
	
	if(_codeBlock == null):
		storedErrors.append("[CrotchScript Error] "+str(_errorText))
	else:
		storedErrors.append("[CrotchScript Error at line "+str(_codeBlock.lineNum)+", block: "+str(_codeBlock.id)+"] "+str(_errorText))

func run():
	buttons.clear()
	
	var currentStateID = scene.getState()
	
	var currentState:DatapackSceneState = datapackScene.states[currentStateID]
	
	var code = currentState.getCode()
	
	execute(code)
	
	if(storedErrors.size() > 0):
		saynn("[color=red]"+Util.join(storedErrors, "\n")+"[/color]")
		storedErrors = []
	
func react(_id, _args):
	if(buttons.has(_id)):
		execute(buttons[_id]["code"])
		scene.setState(buttons[_id]["state"])
		return true
	return false
	
func saveData():
	return {
		"vars": vars,
	}

func loadData(_data):
	vars = loadVar(_data, "vars", {})

func getVar(theVar:String, defaultValue = null):
	if(!vars.has(theVar)):
		if(datapackScene.vars.has(theVar)):
			return datapackScene.vars[theVar]["default"]
	return .getVar(theVar, defaultValue)

func hasVar(theVar:String):
	return vars.has(theVar) || datapackScene.vars.has(theVar)

func loadVar(_data, thekey, defaultValue = null):
	if(_data.has(thekey)):
		return _data[thekey]
	return defaultValue

func addButton(_nameText, _descText, _state, _codeSlot):
	var newButtonID = "button"+str(curButtonIndex)
	
	buttons[newButtonID] = {
		name = _nameText,
		desc = _descText,
		code = _codeSlot,
		state = _state,
	}
	
	scene.addButton(_nameText, _descText, newButtonID)
	
	curButtonIndex += 1

func addDisabledButton(_nameText, _descText):
	scene.addDisabledButton(_nameText, _descText)

func addCharacter(charAlias, _variant):
	if(datapackScene.chars.has(charAlias)):
		scene.addCharacter(datapackScene.chars[charAlias]["realid"], _variant.split("-", false))
	else:
		scene.addCharacter(charAlias, _variant.split("-", false))

func removeCharacter(charAlias):
	if(datapackScene.chars.has(charAlias)):
		scene.removeCharacter(datapackScene.chars[charAlias]["realid"])
	else:
		scene.removeCharacter(charAlias)

# Replaces =charID: at the start of the lines with [say=charID] tags
func processSayStatements(text:String):
	var lines = text.split("\n", true)
	var result:Array = []
	for linea in lines:
		var line:String = linea
		
		if(line.begins_with("=")):
			var splitData = Util.splitOnFirst(line.substr(1), ": ")
			if(splitData.size() < 2):
				result.append(line)
			else:
				result.append("[say="+str(splitData[0]).strip_edges()+"]"+str(splitData[1]).strip_edges()+"[/say]")
		else:
			result.append(line)
	return Util.join(result, "\n")

var simpleStringInterpolator:SimpleStringInterpolator = SimpleStringInterpolator.new()

# Handles things like {{varName}} and {{"meow" if varName else "mow"}}
func processOutputVars(text:String):
	return simpleStringInterpolator.process(text, self)

func processOutputString(text:String):
	return processOutputVars(processSayStatements(text))

func aimCameraAndSetLocName(newLoc):
	scene.aimCameraAndSetLocName(str(newLoc))

func playAnim(animID, animData):
	var finalState = animData["state"]["value"]
	
	var finalAnimData = {}
	if(animData.has("data")):
		for entryID in animData["data"]:
			var theEntry = animData["data"][entryID]
			
			if("." in entryID):
				var splitData = Util.splitOnFirst(entryID, ".")
				var firstThing = splitData[0]
				var secondThing = splitData[1]
				if(!finalAnimData.has(firstThing)):
					finalAnimData[firstThing] = {}
				finalAnimData[firstThing][secondThing] = theEntry["value"]
			else:
				if(entryID in ["pc", "npc", "npc2", "npc3", "npc4"]):
					var theCharID = theEntry["value"]
					
					var resolvedID = scene.resolveCustomCharacterName(theCharID)
					if(resolvedID != null):
						theCharID = resolvedID
					
					finalAnimData[entryID] = theCharID
				else:
					finalAnimData[entryID] = theEntry["value"]
	
	scene.playAnimation(animID, finalState, finalAnimData)
