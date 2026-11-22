local ItemType = require("main.modules.items.item_type")

local ItemClass = {

	SWORD = {
		type = ItemType.WEAPON,
		attack_damage = 10
	},
	AXE = {
		type = ItemType.WEAPON,
		attack_damage = 15
	},
	APPLE = {
		type = ItemType.CONSUMABLE,
		health_restore = 20
	}
}



return ItemClass