extends SexActivityBase

func _init():
	id = "DomPutOnStrapon"
	startedByDom = true
	startedBySub = false

func getGoals():
	return {
	}

func getActivityBaseScore(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	return 0.0

func getStartActions(_sexEngine: SexEngine, _domInfo: SexDomInfo, _subInfo: SexSubInfo):
	var dom:BaseCharacter = _domInfo.getChar()
	var sub:BaseCharacter = _subInfo.getChar()
	var actions = []
	
	var allStraponIds = GlobalRegistry.getItemIDsByTag(ItemTag.Strapon)
	var putOnDomScore = getActivityScoreCustomGoals({SexGoal.SubWearStraponOnDom: 1.0}, _sexEngine, _domInfo, _subInfo) / float(allStraponIds.size())
	var putOnSubScore = getActivityScoreCustomGoals({SexGoal.SubWearStraponOnSub: 1.0}, _sexEngine, _domInfo, _subInfo) / float(allStraponIds.size())
	
	if(!dom.hasPenis() && !dom.getInventory().hasSlotEquipped(InventorySlot.Strapon) && dom.getFirstItemThatCoversBodypart(BodypartSlot.Penis) == null):
		if(dom.isPlayer()):
			for straponObject in dom.getInventory().getItemsWithTag(ItemTag.Strapon):
				actions.append({
					name = straponObject.getVisibleName(),
					desc = straponObject.getVisisbleDescription(),
					args = ["dom", straponObject.uniqueID],
					score = putOnDomScore,
					category = ["Wear", "Strapon"],
				})
		else:
			for straponID in allStraponIds:
				var straponObject:ItemBase = GlobalRegistry.getItemRef(straponID)
				
				actions.append({
					name = straponObject.getVisibleName(),
					desc = straponObject.getVisisbleDescription(),
					args = ["dom", straponID],
					score = putOnDomScore,
					category = ["Wear", "Strapon"],
				})
	if(!sub.hasPenis() && !sub.getInventory().hasSlotEquipped(InventorySlot.Strapon) && sub.getFirstItemThatCoversBodypart(BodypartSlot.Penis) == null):
		if(dom.isPlayer()):
			for straponObject in dom.getInventory().getItemsWithTag(ItemTag.Strapon):
				actions.append({
					name = straponObject.getVisibleName(),
					desc = straponObject.getVisisbleDescription(),
					args = ["sub", straponObject.uniqueID],
					score = putOnSubScore,
					category = ["Wear", "Strapon on sub"],
				})
		else:
			for straponID in allStraponIds:
				var straponObject:ItemBase = GlobalRegistry.getItemRef(straponID)
				
				actions.append({
					name = straponObject.getVisibleName(),
					desc = straponObject.getVisisbleDescription(),
					args = ["sub", straponID],
					score = putOnSubScore,
					category = ["Wear", "Strapon on sub"],
				})
	
	return actions

func getVisibleName():
	return "Wear strapon"

func getCategory():
	return ["Wear"]

func getDomTags():
	return [SexActivityTag.HandsUsed, SexActivityTag.VaginaPenetrated, SexActivityTag.AnusPenetrated]

func getSubTags():
	return []

func startActivity(_args):
	state = ""
	
	endActivity()
	
	if(_args[0] == "dom"):
		var straponItem:ItemBase
		if(getDom().isPlayer()):
			straponItem = getDom().getInventory().getItemByUniqueID(_args[1])
			getSexEngine().addTrackedGear(domID, domID, straponItem.uniqueID)
		else:
			straponItem = GlobalRegistry.createItem(_args[1])
		getDom().getInventory().equipItem(straponItem)
		
		return {
			text = "{dom.You} {dom.youVerb('put')} on a "+straponItem.getCasualName()+".",
			#domSay = domReaction(SexReaction.DomPutsOnACondom),
		}
	
	if(_args[0] == "sub"):
		var straponItem:ItemBase
		if(getDom().isPlayer()):
			straponItem = getDom().getInventory().getItemByUniqueID(_args[1])
			getSexEngine().addTrackedGear(domID, subID, straponItem.uniqueID)
		else:
			straponItem = GlobalRegistry.createItem(_args[1])
		getSub().getInventory().equipItem(straponItem)
		
		return {
			text = "{dom.You} {dom.youVerb('force')} a "+straponItem.getCasualName()+" on {sub.you}.",
			#domSay = domReaction(SexReaction.DomPutsOnACondomOnSub),
		}
