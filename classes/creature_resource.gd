extends Resource

class_name CreatureDescription

enum Attrib {strength, defense, hitpoints}

@export var name:String
@export var featured_attribute:Attrib = Attrib.strength
@export var affinity:String
@export var base_strength:int
@export var base_defense:int
@export var base_hitpoints:int
