extends Node
class_name DialogueIcons

const npc_icons = {
	"Sebastian": {
		"neutral": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Neutral.png")
		},
		"happy": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Happy.png")
		},
		"worry": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Worry.png")
		},
		"worried": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Worry.png")
		},
		"annoyed": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Annoyed.png")
		},
		"angry": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Angry.png")
		},
		"bloody": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Bloody.png")
		},
		"confused": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Confused.png")
		},
		"scared": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Scared.png")
		},
		"tired": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Tired.png")
		},
		"doubt": {
			"body": preload("res://Assets/Sebastian Icon/Seb_Doubt.png")
		}
	},
	"Jacob": {
		"npc": {
			"body": preload("res://Assets/Npc Icons/J_NPC.png")
		}
	},
	" ": {
		"blank": {
			"body": preload("res://Assets/Npc Icons/blank-export.png")
		}
		},
	"Sylas":{
		"angry":{
			"body": preload("res://Assets/Sylas Icon/sy_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/Sylas Icon/sy_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/Sylas Icon/sy_confused.png")
		},
		"doubt":{
			"body": preload("res://Assets/Sylas Icon/sy_doubt.png")
		},
		"happy":{
			"body": preload("res://Assets/Sylas Icon/sy_happy.png")
		},
		"hi":{
			"body": preload("res://Assets/Sylas Icon/sy_hi.png")
		},
		"neutral":{
			"body": preload("res://Assets/Sylas Icon/sy_neutral.png")
		},
		"scared":{
			"body": preload("res://Assets/Sylas Icon/sy_scary.png")
		},
		"worried":{
			"body": preload("res://Assets/Sylas Icon/sy_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/Sylas Icon/sy_worried.png")
		}
	},
	"Evelyn":{
		"angry":{
			"body": preload("res://Assets/Evelyn Icon/eve_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/Evelyn Icon/eve_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/Evelyn Icon/eve_confused.png")
		},
		"doubt":{
			"body": preload("res://Assets/Evelyn Icon/eve_doubt.png")
		},
		"happy":{
			"body": preload("res://Assets/Evelyn Icon/eve_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/Evelyn Icon/eve_neutral.png")
		},
		"scared":{
			"body": preload("res://Assets/Evelyn Icon/eve_scared.png")
		},
		"snarky":{
			"body": preload("res://Assets/Evelyn Icon/eve_snarky.png")
		},
		"worried":{
			"body": preload("res://Assets/Evelyn Icon/eve_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/Evelyn Icon/eve_worried.png")
		}
	},
	"Evan":{
		"angry":{
			"body": preload("res://Assets/Evan Icon/e_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/Evan Icon/e_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/Evan Icon/e_confused.png")
		},
		"happy":{
			"body": preload("res://Assets/Evan Icon/e_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/Evan Icon/e_neutral.png")
		},
		"point":{
			"body": preload("res://Assets/Evan Icon/e_point.png")
		},
		"scared":{
			"body": preload("res://Assets/Evan Icon/e_scared.png")
		},
		"worried":{
			"body": preload("res://Assets/Evan Icon/e_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/Evan Icon/e_worried.png")
		}
	},
	"Connor":{
		"angry":{
			"body": preload("res://Assets/Connor Icon/co_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/Connor Icon/co_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/Connor Icon/co_confused.png")
		},
		"happy":{
			"body": preload("res://Assets/Connor Icon/co_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/Connor Icon/co_neutral.png")
		},
		"scared": {
			"body": preload("res://Assets/Connor Icon/co_scared.png")
		}
	},
	"Silvia":{
		"angry":{
			"body": preload("res://Assets/Silvia Icon/Si_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/Silvia Icon/Si_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/Silvia Icon/Si_confused.png")
		},
		"grossed":{
			"body": preload("res://Assets/Silvia Icon/Si_grossed.png")
		},
		"happy":{
			"body": preload("res://Assets/Silvia Icon/Si_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/Silvia Icon/Si_neutral.png")
		},
		"scared":{
			"body": preload("res://Assets/Silvia Icon/Si_scared.png")
		},
		"worried":{
			"body": preload("res://Assets/Silvia Icon/Si_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/Silvia Icon/Si_worried.png")
		}
	},
	"Cache":{
		"annoyed":{
			"body": preload("res://Assets/Npc Icons/ca_annoyed.png")
		},
		"happy":{
			"body": preload("res://Assets/Npc Icons/ca_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/Npc Icons/ca_neutral.png")
		}
	},
	"Noir":{
		"happy":{
			"body": preload("res://Assets/Npc Icons/n_happy.png")
		},
		"sad":{
			"body": preload("res://Assets/Npc Icons/n_sad.png")
		}
	}
}
