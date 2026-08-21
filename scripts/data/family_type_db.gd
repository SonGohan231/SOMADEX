extends RefCounted

const CORE_TYPES: Array[String] = [
	"REZONANS", "ŚLIZG", "NAPIĘCIE", "OSC", "KIERUNEK", "TORSJA",
	"STABIL", "CZUCIE", "WAVE", "ELECTRIC", "ICE", "FIRE", "PHYSICAL"
]

const FAMILY_TYPES: Dictionary = {
	1:"REZONANS", 2:"ŚLIZG", 3:"ŚLIZG", 4:"NAPIĘCIE", 5:"OSC",
	6:"KIERUNEK", 7:"TORSJA", 8:"KIERUNEK", 9:"STABIL", 10:"CZUCIE",
	11:"REZONANS", 12:"OSC", 13:"CZUCIE", 14:"KIERUNEK", 15:"WAVE",
	16:"ELECTRIC", 17:"REZONANS", 18:"TORSJA", 19:"CZUCIE", 20:"ŚLIZG",
	21:"WAVE", 22:"KIERUNEK", 23:"ELECTRIC", 24:"ELECTRIC", 25:"NAPIĘCIE",
	26:"STABIL", 27:"KIERUNEK", 28:"WAVE", 29:"CZUCIE", 30:"REZONANS",
	31:"FIRE", 32:"STABIL", 33:"NAPIĘCIE", 34:"PHYSICAL", 35:"ŚLIZG",
	36:"NAPIĘCIE", 37:"OSC", 38:"ŚLIZG", 39:"STABIL", 40:"KIERUNEK",
	41:"PHYSICAL", 42:"REZONANS", 43:"STABIL", 44:"KIERUNEK", 45:"WAVE",
	46:"REZONANS", 47:"WAVE", 48:"STABIL", 49:"FIRE", 50:"REZONANS"
}

static func type_for_family(family_id: int) -> String:
	return str(FAMILY_TYPES.get(family_id, "REZONANS"))

static func has_family(family_id: int) -> bool:
	return FAMILY_TYPES.has(family_id)

static func families_for_type(type_id: String) -> Array[int]:
	var result: Array[int] = []
	for raw_family_id: Variant in FAMILY_TYPES.keys():
		if str(FAMILY_TYPES[raw_family_id]) == type_id:
			result.append(int(raw_family_id))
	result.sort()
	return result

static func validate() -> Array[String]:
	var errors: Array[String] = []
	for family_id: int in range(1, 51):
		if not FAMILY_TYPES.has(family_id):
			errors.append("missing family type %d" % family_id)
			continue
		var type_id: String = str(FAMILY_TYPES[family_id])
		if type_id not in CORE_TYPES:
			errors.append("family %d uses unknown type %s" % [family_id, type_id])
	return errors
