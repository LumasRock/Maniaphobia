extends Node

const npc_icons = {
	"Sebastian": {
		"neutral": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Neutral.png")
		},
		"happy": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Happy.png")
		},
		"worry": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Worry.png")
		},
		"worried": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Worry.png")
		},
		"annoyed": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Annoyed.png")
		},
		"angry": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Angry.png")
		},
		"bloody": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Bloody.png")
		},
		"confused": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Confused.png")
		},
		"scared": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Scared.png")
		},
		"tired": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Tired.png")
		},
		"doubt": {
			"body": preload("res://Assets/sprites/portraits/sebastian/Seb_Doubt.png")
		}
	},
	"Jacob": {
		"npc": {
			"body": preload("res://Assets/sprites/portraits/npc/J_NPC.png")
		}
	},
	" ": {
		"blank": {
			"body": preload("res://Assets/sprites/portraits/npc/blank-export.png")
		}
		},
	"Sylas":{
		"angry":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_confused.png")
		},
		"doubt":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_doubt.png")
		},
		"happy":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_happy.png")
		},
		"hi":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_hi.png")
		},
		"neutral":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_neutral.png")
		},
		"scared":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_scary.png")
		},
		"worried":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/sprites/portraits/sylas/sy_worried.png")
		}
	},
	"Evelyn":{
		"angry":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_confused.png")
		},
		"doubt":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_doubt.png")
		},
		"happy":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_neutral.png")
		},
		"scared":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_scared.png")
		},
		"snarky":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_snarky.png")
		},
		"worried":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/sprites/portraits/evelyn/eve_worried.png")
		}
	},
	"Evan":{
		"angry":{
			"body": preload("res://Assets/sprites/portraits/evan/e_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/sprites/portraits/evan/e_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/sprites/portraits/evan/e_confused.png")
		},
		"happy":{
			"body": preload("res://Assets/sprites/portraits/evan/e_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/sprites/portraits/evan/e_neutral.png")
		},
		"point":{
			"body": preload("res://Assets/sprites/portraits/evan/e_point.png")
		},
		"scared":{
			"body": preload("res://Assets/sprites/portraits/evan/e_scared.png")
		},
		"worried":{
			"body": preload("res://Assets/sprites/portraits/evan/e_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/sprites/portraits/evan/e_worried.png")
		}
	},
	"Connor":{
		"angry":{
			"body": preload("res://Assets/sprites/portraits/connor/co_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/sprites/portraits/connor/co_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/sprites/portraits/connor/co_confused.png")
		},
		"happy":{
			"body": preload("res://Assets/sprites/portraits/connor/co_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/sprites/portraits/connor/co_neutral.png")
		},
		"scared": {
			"body": preload("res://Assets/sprites/portraits/connor/co_scared.png")
		}
	},
	"Silvia":{
		"angry":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_angry.png")
		},
		"annoyed":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_annoyed.png")
		},
		"confused":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_confused.png")
		},
		"grossed":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_grossed.png")
		},
		"happy":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_neutral.png")
		},
		"scared":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_scared.png")
		},
		"worried":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_worried.png")
		},
		"worry":{
			"body": preload("res://Assets/sprites/portraits/silvia/Si_worried.png")
		}
	},
	"Cache":{
		"annoyed":{
			"body": preload("res://Assets/sprites/portraits/npc/ca_annoyed.png")
		},
		"happy":{
			"body": preload("res://Assets/sprites/portraits/npc/ca_happy.png")
		},
		"neutral":{
			"body": preload("res://Assets/sprites/portraits/npc/ca_neutral.png")
		}
	},
	"Noir":{
		"happy":{
			"body": preload("res://Assets/sprites/portraits/npc/n_happy.png")
		},
		"sad":{
			"body": preload("res://Assets/sprites/portraits/npc/n_sad.png")
		}
	}
}
