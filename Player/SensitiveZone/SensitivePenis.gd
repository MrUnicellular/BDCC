extends SensitiveZone

func _init():
	zoneName = "Penis"
	
func getSensitivityGainModifier() -> float:
	return 0.2 * (1.0 + max(-1.0, getCustomAttribute(BuffAttribute.SensitivityGainAll) + getCustomAttribute(BuffAttribute.SensitivityGainPenis)))

func getLowSensitivityRestoreRate() -> float:
	return 0.7 * (1.0 + max(-1.0, getCustomAttribute(BuffAttribute.SensitivityRestoreAll) + getCustomAttribute(BuffAttribute.SensitivityRestorePenis)))

func getStimulationGainModifier() -> float:
	return 0.5 / (1.0 + max(-0.9, getCustomAttribute(BuffAttribute.OverstimulationThresholdAll) + getCustomAttribute(BuffAttribute.OverstimulationThresholdPenis)))

func getOverstimSensLoseModifier() -> float:
	return 3.0

func getExtraSensGainModifier() -> float:
	return 0.4

func generateDataFor(_dynamicCharacter):
	var fetishHolder:FetishHolder = _dynamicCharacter.getFetishHolder()
	if(fetishHolder == null):
		return
	
	var fetishValue = fetishHolder.getFetishValue(Fetish.VaginalSexGiving) + fetishHolder.getFetishValue(Fetish.AnalSexGiving)
	if(fetishValue > 0.0):
		sensitivity = 1.0 + RNG.randf_range(0.0, fetishValue*0.3)

func canOrgasm() -> bool:
	return getSensitivity() >= 0.4
