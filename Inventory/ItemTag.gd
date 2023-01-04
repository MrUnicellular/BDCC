extends Object
class_name ItemTag

enum {
	Illegal,
	BDSMRestraint,
	CanBeForcedByGuards,
	Condom,
	SoldByGeneralVendomat,
	SoldByMedicalVendomat,
	SoldByUnderwearVendomat,
	ChastityCage,
	Strapon,
	
	GuardUniform,
	NurseUniform,
	EngineerUniform,
	GeneralInmateUniform,
	HighSecurityInmateUniform,
	SexualDeviantInmateUniform,
}

static func getName(tag):
	if(tag == Illegal):
		return "Illegal"
	if(tag == BDSMRestraint):
		return "Restraint"
	if(tag == Condom):
		return "Condom"
	return "error"
