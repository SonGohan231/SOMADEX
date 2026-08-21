extends RefCounted
const FRAME_W: int = 128
const FRAME_H: int = 128
const COLS: int = 15
const SOURCE_FRAME: int = 20
const ATLAS_SIZE: Vector2i = Vector2i(300, 200)
const CHUNK_DIR: String = "res://data/creatures/battle_sprites/seed20_chunks"
const CHUNK_COUNT: int = 4

const NAMES: Array[String] = [
	"Luzik",
	"Warstwin",
	"Synkronaut",
	"Bocznik",
	"Slizgogon",
	"Horyzontor",
	"Milimik",
	"Drobnoskok",
	"Kwantomruk",
	"Pufek",
	"Pulsopuch",
	"Falomamut",
	"Wahlik",
	"Oscylot",
	"Fazoryb",
	"Kompasik",
	"Oktantor",
	"Kartografon",
	"Srubik",
	"Torsys",
	"Spiralion",
	"uczek",
	"Obiegnik",
	"Labiryntaur",
	"Kotwiczek",
	"Bramnik",
	"Fundamentor",
	"Nasuch",
	"Echouszek",
	"Sensoryks",
	"Dwumik",
	"Synchroap",
	"Chorogrif",
	"Fazik",
	"Kontrafal",
	"Antyfonix",
	"Tropiciel",
	"Dalekoskok",
	"Sieciowid",
	"Przeskok",
	"Wezowiec",
	"Portalnik",
	"Nucik",
	"Wibrospiew",
	"Rezonar",
	"Petelka",
	"Sprzezyk",
	"Cyberwibr",
	"Dudnik",
	"Fazodud",
	"Interferon",
	"Wirutek",
	"Spirydrz",
	"Galaktylion",
	"Hercek",
	"Akceler",
	"Metronotron",
	"Szewik",
	"Blizgacz",
	"Regenerion",
	"Tchnik",
	"Ruchodmuch",
	"Autonomir",
	"Wedrus",
	"Czujokrok",
	"Flowmancer",
	"Iskrokol",
	"Piezousk",
	"Elektrokoral",
	"Spiriskra",
	"Obwodzik",
	"Helikoswietl",
	"Ciezulek",
	"Zawiasaur",
	"Grawititan",
	"Koysik",
	"Bezwadek",
	"Orbitalos",
	"Kropelka",
	"Osemnik",
	"Hydrainfinity",
	"Mostek",
	"Cisnieniak",
	"Pneumost",
	"Echonerw",
	"Synapsik",
	"Neurogryf",
	"Kafelek",
	"Mozaur",
	"Anatomorf",
	"Cieplik",
	"Termopuls",
	"Solarion",
	"Sekundzik",
	"Lepkoskok",
	"Chronozel",
	"Tuipu",
	"Kanaek",
	"Smok_Szlaku",
	"Gunku",
	"Rolobak",
	"Jadeitowy_Walec",
	"Rouru",
	"Kragap",
	"Cynobrowy_Wir",
	"Naku",
	"Unoszek",
	"Zuraw_Chmur",
	"Chanek",
	"Jednopuls",
	"Medytacyjny_Kilin",
	"Mofu",
	"Ksiezycap",
	"Nefrytowy_Ksiezyc",
	"Anan",
	"Punktuspokoj",
	"Straznik_Qi",
	"Dianek",
	"Igopuch",
	"Gwiezdny_Punktor",
	"Hegus",
	"Metalowa_Brama",
	"Biay_Tygrys_Doliny",
	"Neinek",
	"Ognisty_Straznik",
	"Feniks_Wewnetrznej_Bramy",
	"Zuzu",
	"Ziemiomil",
	"Zoty_Kilin_Ziemi",
	"Taierek",
	"Potokrzew",
	"Zielony_Smok_Drewna",
	"Qiwach",
	"Auralis",
	"Smok_Tysiaca_Wachlarzy",
	"Peciutek",
	"Wuxingon",
	"Chimera_Pieciu_Przemian",
	"Orbitka",
	"Ren_Dun",
	"Taotyczny_Waz_Nieba",
	"Danek",
	"Kotwiczan",
	"Straznik_Dolnego_Pola",
	"Lampik",
	"Uwaznik",
	"Latarnik_Ciszy",
	"Mantrik",
	"Tonolotos",
	"Rezonansowy_Garuda",
]

const BLOCKED_QA: Array[String] = [
	"Slizgogon",
	"Horyzontor",
	"Kartografon",
	"Labiryntaur",
	"Fundamentor",
	"Wibrospiew",
	"Flowmancer",
	"Spiriskra",
	"Obwodzik",
	"Ciezulek",
	"Zawiasaur",
	"Bezwadek",
	"Termopuls",
	"Lepkoskok",
	"Dianek",
	"Zielony_Smok_Drewna",
	"Smok_Tysiaca_Wachlarzy",
	"Straznik_Dolnego_Pola",
	"Mantrik",
	"Tonolotos",
]

const ARCHETYPES: Dictionary = {
	"Luzik":"glide", "Warstwin":"glide", "Synkronaut":"glide",
	"Bocznik":"serpent", "Slizgogon":"serpent", "Horyzontor":"serpent",
	"Milimik":"quadruped", "Drobnoskok":"quadruped", "Kwantomruk":"quadruped",
	"Pufek":"quadruped", "Pulsopuch":"quadruped", "Falomamut":"quadruped",
	"Wahlik":"wing-glide", "Oscylot":"wing-glide", "Fazoryb":"wing-glide",
	"Kompasik":"quadruped", "Oktantor":"serpent", "Kartografon":"quadruped",
	"Srubik":"serpent", "Torsys":"serpent", "Spiralion":"serpent",
	"uczek":"serpent", "Obiegnik":"quadruped", "Labiryntaur":"serpent",
	"Kotwiczek":"heavy", "Bramnik":"quadruped", "Fundamentor":"heavy",
	"Nasuch":"pulse", "Echouszek":"wing-glide", "Sensoryks":"pulse",
	"Dwumik":"quadruped", "Synchroap":"quadruped", "Chorogrif":"quadruped",
	"Fazik":"quadruped", "Kontrafal":"quadruped", "Antyfonix":"quadruped",
	"Tropiciel":"serpent", "Dalekoskok":"quadruped", "Sieciowid":"quadruped",
	"Przeskok":"pulse", "Wezowiec":"pulse", "Portalnik":"serpent",
	"Nucik":"wing-glide", "Wibrospiew":"wing-glide", "Rezonar":"wing-glide",
	"Petelka":"wing-glide", "Sprzezyk":"wing-glide", "Cyberwibr":"wing-glide",
	"Dudnik":"wing-glide", "Fazodud":"wing-glide", "Interferon":"wing-glide",
	"Wirutek":"wing-glide", "Spirydrz":"wing-glide", "Galaktylion":"wing-glide",
	"Hercek":"wing-glide", "Akceler":"wing-glide", "Metronotron":"wing-glide",
	"Szewik":"serpent", "Blizgacz":"quadruped", "Regenerion":"serpent",
	"Tchnik":"quadruped", "Ruchodmuch":"quadruped", "Autonomir":"quadruped",
	"Wedrus":"quadruped", "Czujokrok":"pulse", "Flowmancer":"quadruped",
	"Iskrokol":"quadruped", "Piezousk":"quadruped", "Elektrokoral":"serpent",
	"Spiriskra":"serpent", "Obwodzik":"serpent", "Helikoswietl":"serpent",
	"Ciezulek":"heavy", "Zawiasaur":"heavy", "Grawititan":"heavy",
	"Koysik":"quadruped", "Bezwadek":"quadruped", "Orbitalos":"serpent",
	"Kropelka":"quadruped", "Osemnik":"quadruped", "Hydrainfinity":"serpent",
	"Mostek":"wing-glide", "Cisnieniak":"wing-glide", "Pneumost":"wing-glide",
	"Echonerw":"wing-glide", "Synapsik":"wing-glide", "Neurogryf":"wing-glide",
	"Kafelek":"quadruped", "Mozaur":"quadruped", "Anatomorf":"quadruped",
	"Cieplik":"heavy", "Termopuls":"heavy", "Solarion":"serpent",
	"Sekundzik":"serpent", "Lepkoskok":"quadruped", "Chronozel":"serpent",
	"Tuipu":"quadruped", "Kanaek":"quadruped", "Smok_Szlaku":"serpent",
	"Gunku":"quadruped", "Rolobak":"quadruped", "Jadeitowy_Walec":"quadruped",
	"Rouru":"quadruped", "Kragap":"quadruped", "Cynobrowy_Wir":"serpent",
	"Naku":"quadruped", "Unoszek":"quadruped", "Zuraw_Chmur":"quadruped",
	"Chanek":"quadruped", "Jednopuls":"quadruped", "Medytacyjny_Kilin":"hover",
	"Mofu":"quadruped", "Ksiezycap":"quadruped", "Nefrytowy_Ksiezyc":"quadruped",
	"Anan":"quadruped", "Punktuspokoj":"pulse", "Straznik_Qi":"pulse",
	"Dianek":"pulse", "Igopuch":"pulse", "Gwiezdny_Punktor":"pulse",
	"Hegus":"serpent", "Metalowa_Brama":"quadruped", "Biay_Tygrys_Doliny":"serpent",
	"Neinek":"quadruped", "Ognisty_Straznik":"quadruped", "Feniks_Wewnetrznej_Bramy":"quadruped",
	"Zuzu":"quadruped", "Ziemiomil":"quadruped", "Zoty_Kilin_Ziemi":"quadruped",
	"Taierek":"hover", "Potokrzew":"serpent", "Zielony_Smok_Drewna":"serpent",
	"Qiwach":"wing-glide", "Auralis":"wing-glide", "Smok_Tysiaca_Wachlarzy":"wing-glide",
	"Peciutek":"pulse", "Wuxingon":"pulse", "Chimera_Pieciu_Przemian":"pulse",
	"Orbitka":"serpent", "Ren_Dun":"quadruped", "Taotyczny_Waz_Nieba":"serpent",
	"Danek":"heavy", "Kotwiczan":"heavy", "Straznik_Dolnego_Pola":"heavy",
	"Lampik":"wing-glide", "Uwaznik":"wing-glide", "Latarnik_Ciszy":"wing-glide",
	"Mantrik":"wing-glide", "Tonolotos":"wing-glide", "Rezonansowy_Garuda":"wing-glide",
}

static var _atlas_image: Image = null
static var _frame_cache: Dictionary = {}

static func form_count() -> int:
	return NAMES.size()

static func approved_count() -> int:
	return NAMES.size() - BLOCKED_QA.size()

static func blocked_count() -> int:
	return BLOCKED_QA.size()

static func has_name(creature_name: String) -> bool:
	return _index_for(creature_name) >= 0

static func is_approved(creature_name: String) -> bool:
	var idx: int = _index_for(creature_name)
	if idx < 0:
		return false
	return not _blocked_casefold(NAMES[idx])

static func archetype(creature_name: String) -> String:
	var idx: int = _index_for(creature_name)
	if idx < 0:
		return "default"
	return str(ARCHETYPES.get(NAMES[idx], "default"))

static func texture_for(creature_name: String) -> Texture2D:
	var idx: int = _index_for(creature_name)
	if idx < 0 or not is_approved(creature_name):
		return null
	if _frame_cache.has(idx):
		return _frame_cache[idx] as Texture2D
	var image: Image = image_for(creature_name)
	if image == null:
		return null
	var texture: Texture2D = ImageTexture.create_from_image(image)
	_frame_cache[idx] = texture
	return texture

static func image_for(creature_name: String) -> Image:
	var idx: int = _index_for(creature_name)
	if idx < 0 or not is_approved(creature_name):
		return null
	var image: Image = _load_atlas_image()
	if image == null:
		return null
	var region := Rect2i((idx % COLS) * SOURCE_FRAME, int(idx / COLS) * SOURCE_FRAME, SOURCE_FRAME, SOURCE_FRAME)
	var result: Image = image.get_region(region)
	result.resize(FRAME_W, FRAME_H, Image.INTERPOLATE_NEAREST)
	return result

static func _load_atlas_image() -> Image:
	if _atlas_image != null:
		return _atlas_image
	var encoded: String = ""
	for index: int in range(CHUNK_COUNT):
		var path: String = "%s/part_%02d.b64.txt" % [CHUNK_DIR, index]
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_error("Missing SOMADEX seed atlas chunk: %s" % path)
			return null
		encoded += file.get_as_text().strip_edges()
	var bytes: PackedByteArray = Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("SOMADEX seed atlas base64 decode failed")
		return null
	var image := Image.new()
	var error: Error = image.load_png_from_buffer(bytes)
	if error != OK:
		push_error("SOMADEX seed atlas PNG decode failed: %s" % error)
		return null
	if Vector2i(image.get_size()) != ATLAS_SIZE:
		push_error("SOMADEX seed atlas image size mismatch: %s" % image.get_size())
		return null
	_atlas_image = image
	return _atlas_image

static func _index_for(creature_name: String) -> int:
	var target: String = creature_name.strip_edges().to_lower()
	for i: int in range(NAMES.size()):
		if NAMES[i].to_lower() == target:
			return i
	return -1

static func _blocked_casefold(creature_name: String) -> bool:
	var target: String = creature_name.to_lower()
	for name: String in BLOCKED_QA:
		if name.to_lower() == target:
			return true
	return false
