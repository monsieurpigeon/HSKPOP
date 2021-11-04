extends Control

const SQLite = preload("res://addons/godot-sqlite/bin/gdsqlite.gdns")
var db # DB Object
var db_name = "res://DataStore/database" #Path to DB

# Called when the node enters the scene tree for the first time.
func _ready():
	db = SQLite.new()
	db.path = db_name
	readFromDb()

func commitDataToDb():
	db.open_db()
	var tableName = "trace"
	var dict : Dictionary = Dictionary()
	dict["created_at"] = 42
	dict["content"] = "Hello World"
	db.insert_row(tableName, dict)

func readFromDb():
	db.open_db()
	var tableName = "hanzi"
	db.query("select * from " + tableName + ";")
	for i in range(0, db.query_result.size()):
		print("Query results", db.query_result[i]["character"])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
