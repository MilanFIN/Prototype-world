extends Node

"""
TODO:
	Raycast kropasta alaspäin. ota sijainti talteen, ja aseta jalka sijaintiin
	Kun raycastin uusi sijainti on tarpeeksi kaukana edellisestä, niin 
	ota uusi sijainti targetiksi, ja siirrä jalka siihen kaaressa 
	
	(pitäis tehdä jotenkin sinifunktiolla korkeus suhteessa: 
		skaalaa sijaintia
		alku -> 0 vastaava arvo
		loppu -> PI vastaava arvo
		väli -> "0-PI" välillä
	sin saa arvon 0->1->0 välillä 0->pi/2->pi
	)
	
	lopuksi joku inverse kinematics laskuri saa selvittää kulmat, jotta päästään
	tavoitteeseen

	aluksi esim pallo, jolla on yksi jalka
	jalka pomppii alla samalla kun pallo liikkuu ympäriinsä
	
"""



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
	
func _process(delta: float) -> void:
	var playerPos = get_node("Player").translation

	get_node("Terrain").check(playerPos)
	


	#if (delta >= 0.017):
	#	print("SLOW!: ", delta)
