extends EventBase

func _init():
	id = "SlaveryWalkiesInteractionEvents"

func registerTriggers(es):
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "main_bathroom1")
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "main_bathroom2")
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "main_dressing1")
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "main_dressing2")
	es.addTrigger(self, Trigger.EnteringRoomWithSlave, "main_punishment_spot")

func run(_triggerID, _args):
	var locName = _args[0]
	var npcID = _args[1]
	var theChar:DynamicCharacter = GlobalRegistry.getCharacter(npcID)
	var npcSlavery:NpcSlave = theChar.getNpcSlavery()
	
	if(locName in ["main_bathroom1", "main_bathroom2"]):
		if(npcSlavery.getLevel() >= 1):
			addButton("Mirror (Slave)", "Change your slave's haircut", "starthair", [npcID])
		else:
			addDisabledButton("Mirror (Slave)", "Slave level 1+ required to do this")

	if(locName in ["main_dressing1", "main_dressing2"]):
		addButton("Shower (Slave)", "Make your slave take a shower", "startshower", [npcID])

	if(locName in ["main_punishment_spot"]):
		addButton("Stocks (Slave)", "Put your slave into the stocks", "startstocks", [npcID])

	
func getPriority():
	return 0

func onButton(_method, _args):
	if(_method == "starthair"):
		runScene("ActionSlaveryHaircut", [_args[0]])
	if(_method == "startshower"):
		runScene("ActionSlaveryShower", [_args[0]])
	if(_method == "startstocks"):
		GM.main.endCurrentScene()
		runScene("PunishSlaveryLeaveInStocks", [_args[0]])
