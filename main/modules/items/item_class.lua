local ItemType = require("main.modules.items.item_type")
local AttackType = require("main.modules.items.attack_type")

local ItemClass = {

	SWORD = {
		type = ItemType.WEAPON,
		attack_damage = 10,
		max_sweep = 45,
		reach = 14,
		use = {
			attack_type = AttackType.SWEEP
		}
	},
	AXE = {
		type = ItemType.WEAPON,
		attack_damage = 15,
		max_sweep = 120,
		reach = 14,
		use = {
			attack_type = AttackType.SWEEP
		}
	},
	APPLE = {
		type = ItemType.CONSUMABLE,
		health_restore = 20
	}
}



return ItemClass