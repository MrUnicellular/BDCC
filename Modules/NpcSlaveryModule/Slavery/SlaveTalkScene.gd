extends "res://Scenes/SceneBase.gd"

var npcID = ""
var npc:DynamicCharacter
var resultText = ""

var savedWantedToDo = ""
var savedWantedToDoName = ""
var savedWantedToDoArgs = []

func _init():
	sceneID = "SlaveTalkScene"

func _initScene(_args = []):
	npcID = _args[0]
	npc = GlobalRegistry.getCharacter(npcID)
	
	
func resolveCustomCharacterName(_charID):
	if(_charID == "npc"):
		return npcID

func _run():
	if(state == ""):
		addCharacter(npcID)
		playAnimation(StageScene.Duo, "stand", {npc=npcID, npcBodyState={chains=[["normal", "neck", "scene", "floor"]]} })
		
		var npcSlavery:NpcSlave = npc.getNpcSlavery()
		if(npcSlavery == null):
			saynn("Something went wrong")
			addButton("Back", "Enough interactions", "endthescene")
			return
		npcSlavery.checklevelUp()
		
		saynn(npc.getName()+" is a level "+str(npcSlavery.slaveLevel)+" slave")
		saynn("{npc.He} {npc.isAre} standing still, {npc.his} collar leashed to the floor.")
		
		if(npcSlavery.getDespair() > 0.5):
			saynn("{npc.name} looks pretty depressed.")
		elif(npcSlavery.getDespair() > 0.8):
			saynn("[b]{npc.name} looks extremely depressed.[/b] {npc.He} {npc.isAre} close to snapping.")
		
		if(npcSlavery.getWorkEfficiency() < 0.2):
			saynn("{npc.name} looks very tired.")
		
		saynn(npcSlavery.getRewardBalanceString())
		
		if(true):
			sayn("[b]DEBUG INFO:[/b]")
			saynn(npcSlavery.getDebugInfo())
			
		if(false):
			sayn("[b]Personality:[/b]")
			var personality: Personality = npc.getPersonality()
			if(personality != null):
				var texts = []
				for statID in PersonalityStat.getAll():
					var value = personality.getStat(statID)
					var statName = PersonalityStat.getVisibleName(statID)
					var statValue = PersonalityStat.getVisibleDesc(statID, value)
					
					texts.append(statName+": "+statValue)
				saynn(Util.join(texts, "\n"))
		
		sayn("[b]Skills:[/b]")
		for skillID in npcSlavery.slaveSpecializations:
			var slaveType:SlaveTypeBase = GlobalRegistry.getSlaveType(skillID)
			if(slaveType == null):
				continue
			var gradeLetter = npcSlavery.rankToLetter(npcSlavery.slaveSpecializations[skillID])
			
			sayn(""+slaveType.getVisibleName()+": "+gradeLetter)
		sayn("")
		
		addButton("Talk", "Tell something to your slave", "talk_menu")
		addButtonWithChecks("Train", "Train your slave", "do_train", [], [[ButtonChecks.NotLate], [ButtonChecks.NotGagged], [ButtonChecks.NotBlindfolded]])
		addButtonAt(13, "Forced sex", "Start sex with your slave", "do_forced_sex")
		addButton("Reward", "Show a list of rewards", "rewards_menu")
		addButton("Punish", "Show a list of punishments", "punishments_menu")
		addButtonAt(14, "Back", "Enough interactions", "endthescene")

	if(state == "talk_menu"):
		saynn("What do you want to tell your slave?")
		
		addButtonsForActionsOfType(SlaveActionBase.Talk)

		addButton("Back", "You changed your mind!", "")

	if(state == "rewards_menu"):
		saynn("How do you want to reward your slave?")
		
		addButtonsForActionsOfType(SlaveActionBase.Reward)

		addButton("Back", "You changed your mind!", "")

	if(state == "punishments_menu"):
		saynn("How do you want to punish your slave?")
		
		addButtonsForActionsOfType(SlaveActionBase.Punishment)

		addButton("Back", "You changed your mind!", "")

	if(state == "do_action"):
		saynn(resultText)
		
		addButton("Continue", "See what happens next", "")

	if(state == "do_train"):
		saynn(resultText)
		
		addButton("Continue", "See what happens next", "")
	
	if(state == "resisting_action"):
		saynn("Your slave is actively resisting any attempts to do anything with {npc.him}!")
		
		addButton("Okay", "You changed your mind", "forced_sex_let_resist")
		addButton("Fight them", "Force them through fighting", "resisting_start_fight")
	
	if(state == "resisting_scratch"):
		saynn("Your slave scratched you!")
		
		addAfterForceButton()
		addButton("Fight them", "Force them through fighting", "resisting_start_fight")
		addButton("Punish", "Show a list of punishments", "punishments_menu")
	
	if(state == "forced_sex_resist"):
		saynn("Your slave is trying to resist! You will have to force them by beating them up first!")
		
		addButton("Never mind", "You changed your mind", "forced_sex_let_resist")
		addButton("Fight", "Force them through fighting", "forced_sex_startfight")
		
	if(state == "won_forcedsex"):
		saynn("You won!")
		
		addButton("Fuck them", "Do what you wanted to do with them", "start_forced_sex_forced")
		addButton("Never mind", "You don't want to fuck them anymore", "")
	
	if(state == "won_resistaction"):
		saynn("You won!")
		
		addAfterForceButton()
		addButton("Cancel", "They should resist less at least", "")
	
	if(state == "lost_forcedsex"):
		saynn("You lost. Aw.")
		
		addButton("Never mind", "You don't want to fuck with them anymore", "forced_sex_let_resist")
		
func addButtonsForActionsOfType(actionsType):
	for actionID in GlobalRegistry.getSlaveActionIDsOfType(actionsType):
		var theAction:SlaveActionBase = GlobalRegistry.getSlaveAction(actionID)
		
		if(theAction.extraSlaves.empty()):
			var canDoInfo = theAction.checkCanDoFinal(npcID)
			if(canDoInfo[0]):
				addButton(theAction.getVisibleName(), theAction.getVisibleDesc(), "do_action", [actionID])
			elif(canDoInfo.size() > 1):
				addDisabledButton(theAction.getVisibleDesc(), canDoInfo[1])
		else:
			addButton(theAction.getVisibleName(), theAction.getVisibleDesc(), "do_action", [actionID])

func addAfterForceButton():
	addButton(savedWantedToDoName, "Do what you wanted to do", savedWantedToDo, savedWantedToDoArgs)

func setStateResistance():
	var npcSlavery:NpcSlave = npc.getNpcSlavery()
	var possible = [["resisting_action", 1.0]]
	if(true):
		possible.append(["resisting_scratch", 1.0])
	var pickedRandom = RNG.pickWeightedPairs(possible)
	
	if(pickedRandom == "resisting_scratch"):
		GM.pc.addPain(RNG.randi_range(2, 5))
		npcSlavery.deservesPunishment(2)
	else:
		npcSlavery.deservesPunishment(1)
		
	setState(pickedRandom)
	return true
		
func _react(_action: String, _args):
	if(_action == "endthescene"):
		endScene()
		return
	
	if(_action == "do_action"):
		var theAction:SlaveActionBase = GlobalRegistry.getSlaveAction(_args[0])
		var npcSlavery:NpcSlave = npc.getNpcSlavery()
		
		# Resisting!
		var resistChance = (100.0*float(npcSlavery.isResistingSuperActively()) + 40.0*float(npcSlavery.isActivelyResisting())) * theAction.slaveResistChanceMult
		if(RNG.chance(resistChance)):
			# Various resisting actions here?
			# Like scratching/biting/shoving/kicking (if no restraints)
			savedWantedToDo = "do_action_noresist"
			savedWantedToDoName = "Do action"
			savedWantedToDoArgs = [_args[0]]
			setStateResistance()
			return
		
	if(_action == "do_action" || _action == "do_action_noresist"):
		var theAction:SlaveActionBase = GlobalRegistry.getSlaveAction(_args[0])
		#var npcSlavery:NpcSlave = npc.getNpcSlavery()
		# Multi-slave action
		if(!theAction.extraSlaves.empty()):
			runScene("SlaveStartActionScene", [theAction.id, npcID], "slaveStartAction")
			setState("")
			return
		
		# Action that launches a scene
		if(theAction.sceneID != ""):
			runScene("SlaveActionWrapperScene", [theAction.id, npcID, {}])
			if(theAction.endsTalkScene):
				endScene()
				return
			setState("")
			return
		# Simple action
		var result = theAction.doActionSimple(npcID)
		if(result.has("text")):
			resultText = result["text"]
		else:
			resultText = "An action happened!"
		setState("do_action")
		return

	if(_action == "do_train"):
		var npcSlavery:NpcSlave = npc.getNpcSlavery()
		var resistChance = max(80.0*float(npcSlavery.isResistingSuperActively()), 30.0*float(npcSlavery.isActivelyResisting()))
		if(RNG.chance(resistChance)):
			# Various resisting actions here?
			# Like scratching/biting/shoving/kicking (if no restraints)
			savedWantedToDo = "do_train_noresist"
			savedWantedToDoName = "Train"
			savedWantedToDoArgs = []
			setStateResistance()
			return
		
	if(_action == "do_train" || _action == "do_train_noresist"):
		var npcSlavery:NpcSlave = npc.getNpcSlavery()
		var result = npcSlavery.doTrain()
		resultText = Util.join(result["texts"], "\n\n")
		setState("do_train")
		return

	if(_action == "forced_sex_startfight"):
		runScene("FightScene", [npcID], "forcedsexfight")
		return

	if(_action == "resisting_start_fight"):
		runScene("FightScene", [npcID], "antiresistancefight")
		return

	if(_action == "do_forced_sex"):
		var npcSlavery:NpcSlave = npc.getNpcSlavery()
		if(npcSlavery.isResistingSuperActively() || (RNG.chance(40) && npcSlavery.isActivelyResisting())):
			savedWantedToDo = "start_forced_sex_forced"
			savedWantedToDoName = "Forced sex"
			savedWantedToDoArgs = []
			setStateResistance()
		else:
			startSex()
		return
	
	if(_action == "start_forced_sex_forced"):
		startSex(true)
		return
		
	if(_action == "forced_sex_let_resist"):
		# Raise the spirit here?
		setState("")
		return

	setState(_action)

func startSex(isResisting = false):
	if(isResisting):
		npc.addEffect("SexActivelyResisting")
	runScene("GenericSexScene", ["pc", npcID], "sex_with_slave")

func _react_scene_end(_tag, _result):
	if(_tag == "slaveStartAction"):
		if(_result is Array && _result.size() > 0 && _result[0]):
			endScene()
			return
			
	if(_tag in ["sex_with_slave"]):
		setState("")
	
	if(_tag == "antiresistancefight"):
		processTime(10 * 60)
		var battlestate = _result[0]
		#var wonHow = _result[1]
		
		if(battlestate == "win"):
			setState("won_resistaction")
			addExperienceToPlayer(10)
			var npcSlavery:NpcSlave = npc.getNpcSlavery()
			npcSlavery.afterBeatenUp()
			npcSlavery.deservesPunishment(2)
			#npcSlavery.handlePunishment(2)
		else:
			setState("lost_forcedsex")
			var npcSlavery:NpcSlave = npc.getNpcSlavery()
			npcSlavery.deservesPunishment(2)
	
	if(_tag == "forcedsexfight"):
		processTime(10 * 60)
		var battlestate = _result[0]
		#var wonHow = _result[1]
		
		if(battlestate == "win"):
			setState("won_forcedsex")
			addExperienceToPlayer(10)
			var npcSlavery:NpcSlave = npc.getNpcSlavery()
			npcSlavery.afterBeatenUp()
			#npcSlavery.handlePunishment(2)
		else:
			setState("lost_forcedsex")
			var npcSlavery:NpcSlave = npc.getNpcSlavery()
			npcSlavery.deservesPunishment(2)

func saveData():
	var data = .saveData()
	
	data["npcID"] = npcID
	data["resultText"] = resultText
	data["savedWantedToDo"] = savedWantedToDo
	data["savedWantedToDoName"] = savedWantedToDoName
	data["savedWantedToDoArgs"] = savedWantedToDoArgs
	
	return data
	
func loadData(data):
	.loadData(data)
	
	npcID = SAVE.loadVar(data, "npcID", "")
	npc = GlobalRegistry.getCharacter(npcID)

	resultText = SAVE.loadVar(data, "resultText", "")
	savedWantedToDo = SAVE.loadVar(data, "savedWantedToDo", "")
	savedWantedToDoName = SAVE.loadVar(data, "savedWantedToDoName", "")
	savedWantedToDoArgs = SAVE.loadVar(data, "savedWantedToDoArgs", null)

func getDebugActions():
	return [
		{
			"id": "levelUP",
			"name": "Slave levelup",
			"args": [
			],
		},
		{
			"id": "skillLevelup",
			"name": "Skill levelup",
			"args": [
			],
		},
	]

func doDebugAction(_id, _args = {}):
	var npcSlavery:NpcSlave = npc.getNpcSlavery()
	if(_id == "levelUP"):
		npcSlavery.doLevelup()
	if(_id == "skillLevelup"):
		npcSlavery.levelupCurrentSpecialization()
		
