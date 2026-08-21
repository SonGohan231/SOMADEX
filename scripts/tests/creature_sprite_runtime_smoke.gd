extends SceneTree

const SPRITES = preload("res://scripts/battle/battle_sprite_art.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const SEED_MANIFEST: String = "res://data/creatures/battle_sprites/seed_manifest.csv"

const FULL_FAMILIES: Array = [
	[["Nucik","Wibrospiew","Rezonar"],"family015"],
	[["Nasuch","Echouszek","Sensoryks"],"family010"],
	[["Kotwiczek","Bramnik","Fundamentor"],"family009"],
	[["Uczek","Obiegnik","Labiryntaur"],"family008"],
	[["Srubik","Torsys","Spiralion"],"family007"],
	[["Kompasik","Oktantor","Kartografon"],"family006"],
	[["Wahlik","Oscylot","Fazoryb"],"family005"],
	[["Pufek","Pulsopuch","Falomamut"],"family004"],
	[["Milimik","Drobnoskok","Kwantomruk"],"family003"],
	[["Bocznik","Slizgogon","Horyzontor"],"family002"]
]

func _initialize() -> void:
	var errors: Array[String] = []
	var expected_counts: Dictionary = {"idle":4,"attack":6,"hurt":3,"faint":5,"special":6}
	_expect(SPRITES.FRAME_W==128 and SPRITES.FRAME_H==128,"battle sprite frame must be 128x128",errors)
	_expect(SPRITES.animation_count()==150,"battle sprite runtime must expose all 150 forms",errors)
	_expect(SPRITES.production_atlas_approved_count()==130,"production atlas must expose exactly 130 QA-approved forms",errors)
	for action: String in SPRITES.ACTIONS:
		_expect(SPRITES.frame_count(action)==int(expected_counts[action]),"wrong frame count for %s" % action,errors)
	for creature_name: String in SPRITES.animated_names():
		_expect(MONSTERS.has_monster(creature_name),"sprite catalog references missing creature: %s" % creature_name,errors)
		for action: String in SPRITES.ACTIONS:
			var last_frame: int=SPRITES.frame_count(action)-1
			_expect(SPRITES.frame_texture(creature_name,action,0)!=null,"%s %s frame 0 is blank" % [creature_name,action],errors)
			_expect(SPRITES.frame_texture(creature_name,action,last_frame)!=null,"%s %s final frame is blank" % [creature_name,action],errors)
	_expect(SPRITES.authored_seed_count()>=3,"expected at least three authored transparent seeds",errors)
	_expect(SPRITES.authored_full_animation_count()>=30,"reverse pass must contain at least thirty fully animated forms",errors)
	for entry in FULL_FAMILIES: _test_full_family(entry[0],entry[1],errors)
	_validate_seed_manifest(errors)
	_validate_logical_animation_contract(errors)
	if errors.is_empty():
		print("CREATURE_SPRITE_RUNTIME_SMOKE: PASS · 150 forms · 130 approved · 20 blocked · 750 logical states · 30 authored full animations")
		quit(0); return
	for text: String in errors: printerr("CREATURE_SPRITE_RUNTIME_SMOKE: "+text)
	quit(1)

func _test_full_family(names: Array, family_label: String, errors: Array[String]) -> void:
	for raw_name in names:
		var creature_name: String=str(raw_name)
		_expect(SPRITES.has_authored_full_animation(creature_name),"%s %s full animation missing" % [family_label,creature_name],errors)
		_expect(SPRITES.source_kind(creature_name)=="sprite-strip-authored-runtime","%s %s must retain authored priority" % [family_label,creature_name],errors)
		for action: String in SPRITES.ACTIONS:
			var first: Texture2D=SPRITES.frame_texture(creature_name,action,0)
			var last: Texture2D=SPRITES.frame_texture(creature_name,action,SPRITES.frame_count(action)-1)
			_expect(first!=null and Vector2i(first.get_size())==Vector2i(128,128),"%s %s %s first frame failed" % [family_label,creature_name,action],errors)
			_expect(last!=null and Vector2i(last.get_size())==Vector2i(128,128),"%s %s %s last frame failed" % [family_label,creature_name,action],errors)
			if first!=null and last!=null and SPRITES.frame_count(action)>1:
				var a: Image=first.get_image(); var b: Image=last.get_image()
				if a!=null and b!=null: _expect(a.get_data()!=b.get_data(),"%s %s %s repeats static frame" % [family_label,creature_name,action],errors)

func _validate_seed_manifest(errors: Array[String]) -> void:
	var file:=FileAccess.open(SEED_MANIFEST,FileAccess.READ)
	_expect(file!=null,"150-form seed manifest missing",errors)
	if file==null: return
	file.get_csv_line()
	var row_count: int=0; var families: Dictionary={}; var names: Dictionary={}; var approved: int=0; var blocked: int=0
	while not file.eof_reached():
		var row: PackedStringArray=file.get_csv_line()
		if row.size()<9 or row[0].strip_edges().is_empty(): continue
		row_count+=1
		var family_id: int=int(row[0]); var creature_name: String=row[2].strip_edges(); var key:=creature_name.to_lower()
		families[family_id]=int(families.get(family_id,0))+1
		_expect(not names.has(key),"duplicate creature in seed manifest: %s" % creature_name,errors); names[key]=true
		_expect(row[7]=="128x128","%s seed frame contract mismatch" % creature_name,errors)
		_expect(row[8]=="bottom-center","%s seed anchor contract mismatch" % creature_name,errors)
		var status:=row[5].strip_edges()
		if status=="approved": approved+=1
		elif status=="blocked_qa": blocked+=1
		else: _expect(false,"%s has invalid QA status %s" % [creature_name,status],errors)
	for creature_name: String in MONSTERS.all_names(): _expect(names.has(creature_name.to_lower()),"seed manifest drift: %s missing" % creature_name,errors)
	_expect(row_count==150,"expected 150 seed manifest rows, got %d" % row_count,errors)
	_expect(families.size()==50,"expected 50 seed manifest families, got %d" % families.size(),errors)
	for raw_family_id: Variant in families.keys(): _expect(int(families[raw_family_id])==3,"family %s does not contain exactly three forms" % str(raw_family_id),errors)
	_expect(approved==130,"expected 130 approved seeds, got %d" % approved,errors)
	_expect(blocked==20,"expected 20 QA-blocked seeds, got %d" % blocked,errors)

func _validate_logical_animation_contract(errors: Array[String]) -> void:
	var total: int=SPRITES.animation_count()*SPRITES.ACTIONS.size()
	var accepted: int=SPRITES.production_atlas_approved_count()*SPRITES.ACTIONS.size()
	_expect(total==750,"expected 750 logical animations, got %d" % total,errors)
	_expect(accepted==650,"expected 650 accepted logical animations, got %d" % accepted,errors)
	_expect(total-accepted==100,"expected 100 QA-blocked logical animations, got %d" % (total-accepted),errors)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition: errors.append(message)
