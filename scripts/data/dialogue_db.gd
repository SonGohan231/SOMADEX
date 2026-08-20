extends RefCounted

static func text(zone_id: String, tile_code: String, flags: Dictionary) -> String:
	if zone_id == "vela":
		match tile_code:
			"N":
				if bool(flags.get("talked_mira", false)):
					return "Mira: Szlak jest otwarty. Zmieniaj partnerów i obserwuj reakcje statusów."
				return "Mira: W trawie pojawiają się dzikie Somaskany.\nPo ruchu partnera możesz wydać komendę trenera."
			"S": return "TABLICA: VELA\n↑ Szlak Rezonansu     ← Staw Odbić\nStacja Vela regeneruje całą drużynę."
			"C": return "STACJA VELA\nSynchronizacja przywraca HP całej drużynie i zapisuje postęp."
			"H": return "Dom Gildii Techników jest jeszcze zamknięty.\nModuły wyposażenia działają już w profilu trenera."
	if zone_id == "resonance_route":
		match tile_code:
			"N":
				if bool(flags.get("talked_route_scout", false)):
					return "Badacz Ivo: Reakcje pola są powtarzalne. To dobry teren do testowania drużyny."
				return "Badacz Ivo: Nie każdy status zadaje obrażenia.\nNiektóre tworzą reakcje z typem następnego ruchu."
			"S": return "TABLICA: SZLAK REZONANSU\n↓ Vela     ↑ dalsza część regionu (w produkcji treści)"
	return ""

static func flag_for(zone_id: String, tile_code: String) -> String:
	if zone_id == "vela" and tile_code == "N": return "talked_mira"
	if zone_id == "resonance_route" and tile_code == "N": return "talked_route_scout"
	return ""
