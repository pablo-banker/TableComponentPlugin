extends Node
class_name RowUtils

static func generate_random_first_name() -> String:
	var first_names = [
		"John", "Jane", "Michael", "Emily", "Daniel", "Sarah", "David", "Jessica",
		"James", "Mary", "Robert", "Linda", "William", "Patricia", "Thomas", "Elizabeth"
	]
	
	var first_name = first_names[randi() % first_names.size()]
	
	return first_name

static func generate_random_age(min_age: int = 18, max_age: int = 99) -> int:
	return randi() % (max_age - min_age + 1) + min_age

static func generate_random_feeling() -> String:
	var feelings = [
		"Happy", "Sad", "Excited", "Nervous", "Angry", "Surprised", "Confused", "Content",
		"Anxious", "Relaxed", "Curious", "Bored", "Grateful", "Hopeful", "Frustrated", "Joyful"
	]
	
	var feeling = feelings[randi() % feelings.size()]
	
	return feeling
