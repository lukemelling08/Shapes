local DrawItems = {}

local ItemClass = require("main.modules.items.item_class")
local ItemType = require("main.modules.items.item_type")

local sprites = {
	SWORD = {
		-- Handle
		{x = 0, y = 0, colour = {0.45, 0.25, 0.12, 1}},
		{x = 0, y = 1, colour = {0.45, 0.25, 0.12, 1}},
		{x = 0, y = 2, colour = {0.45, 0.25, 0.12, 1}},

		-- Guard
		{x = -1, y = 2, colour = {0.45, 0.25, 0.12, 1}},
		{x = 1, y = 2, colour = {0.45, 0.25, 0.12, 1}},

		-- Blade
		{x = 0, y = 3, colour = {1, 1, 1, 1}},
		{x = 0, y = 4, colour = {1, 1, 1, 1}},
		{x = 0, y = 5, colour = {1, 1, 1, 1}},
		{x = 0, y = 6, colour = {1, 1, 1, 1}},
		{x = 0, y = 7, colour = {1, 1, 1, 1}}
	},
	APPLE = {
		-- Main body
		{x = 0, y = 0, colour = {0.85, 0.05, 0.05, 1}},
		{x = -1, y = 0, colour = {0.85, 0.05, 0.05, 1}},
		{x = 1, y = 0, colour = {0.85, 0.05, 0.05, 1}},
		{x = 0, y = 1, colour = {0.85, 0.05, 0.05, 1}},
		{x = -1, y = 1, colour = {0.85, 0.05, 0.05, 1}},
		{x = 1, y = 1, colour = {0.85, 0.05, 0.05, 1}},
		{x = 0, y = 2, colour = {0.85, 0.05, 0.05, 1}},

		-- Leaf
		{x = 1, y = 3, colour = {0.1, 0.65, 0.1, 1}},

		-- Stem
		{x = 0, y = 3, colour = {0.35, 0.2, 0.1, 1}}
	},
	AXE = {
		-- Handle
		{x = 0, y = -2, colour = {0.4, 0.22, 0.1, 1}},
		{x = 0, y = -1, colour = {0.4, 0.22, 0.1, 1}},
		{x = 0, y = 0, colour = {0.4, 0.22, 0.1, 1}},
		{x = 0, y = 1, colour = {0.4, 0.22, 0.1, 1}},
		{x = 0, y = 2, colour = {0.4, 0.22, 0.1, 1}},
		{x = 0, y = 3, colour = {0.4, 0.22, 0.1, 1}},
		{x = 0, y = 4, colour = {0.4, 0.22, 0.1, 1}},

		-- Axe head
		{x = 1, y = 3, colour = {0.65, 0.68, 0.72, 1}},
		{x = 2, y = 2, colour = {0.65, 0.68, 0.72, 1}},
		{x = 2, y = 3, colour = {0.65, 0.68, 0.72, 1}},
		{x = 2, y = 4, colour = {0.65, 0.68, 0.72, 1}},
		{x = 3, y = 2, colour = {0.8, 0.82, 0.85, 1}},
		{x = 3, y = 3, colour = {0.8, 0.82, 0.85, 1}},
		{x = 3, y = 4, colour = {0.8, 0.82, 0.85, 1}}
	}
}

function DrawItems:get_item_sprite(item_id)
	return sprites[item_id]
end

function DrawItems:draw_item_sprite(renderer, sprite, origin_x, origin_y, size, flip_x)
	if not sprite then return end

	for _, pixel in ipairs(sprite) do
		local x = pixel.x

		if flip_x then
			x = -x
		end

		renderer:create_shape(
			size,
			size,
			origin_x + x * size,
			origin_y + pixel.y * size,
			0,
			pixel.colour
		)
	end
end

function DrawItems:draw_item(renderer, entity, item_id, dt)
	local item = ItemClass[item_id]
	if not item then return end

	local sprite = self:get_item_sprite(item_id)
	if not sprite then return end

	local size = 1
	local flip_x = math.cos(entity.aim_rotation) < 0

	local facing = flip_x and -1 or 1
	local target_offset = facing * (entity.dimensions.width / 2 + 2)

	entity.held_item_offset_x = entity.held_item_offset_x or target_offset
	entity.held_item_offset_x = entity.held_item_offset_x
	+ (target_offset - entity.held_item_offset_x) * math.min(1, 12 * dt)

	local origin_x = entity.pos.x + entity.held_item_offset_x
	local origin_y = entity.pos.y - entity.dimensions.height * 0.3

	self:draw_item_sprite(renderer, sprite, origin_x, origin_y, size, flip_x)
end

return DrawItems