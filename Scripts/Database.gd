extends Control

var db # DB Object
var hanzi_path = "res://DataStore/hanzi.txt" #Path to DB
var dictionnary = [];
var size;
var rng;
var counter = 0;

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	readFromDb()

func commitDataToDb():
	pass

func readFromDb():
	var file = File.new()
	var err = file.open(hanzi_path, File.READ)
	if err != OK:
		printerr("Could not open file, error code ", err)
		return ""
	while not file.eof_reached():
		var line = file.get_csv_line(",")
		print(line, line.size())
		if (line.size() > 1):
			dictionnary.push_back({"character":line[0], "pinyin": line[1], "translation": line[2]})
	file.close()
	print(dictionnary)
	size = dictionnary.size()
	$Label.text = dictionnary[0].character
	$Timer.start()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$Label.text = dictionnary[counter].character
	counter += 1
	counter %= size
