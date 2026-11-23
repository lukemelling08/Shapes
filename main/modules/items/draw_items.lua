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

function DrawItems:draw_item_sprite(renderer, sprite, origin_x, origin_y, size, flip_x, rotation)
	if not sprite then return end

	rotation = rotation or 0
	local cos = math.cos(rotation)
	local sin = math.sin(rotation)

	for _, pixel in ipairs(sprite) do
		local x = pixel.x

		if flip_x then
			x = -x
		end

		local px = x * size
		local py = pixel.y * size

		renderer:create_shape(
			size,
			size,
			origin_x + px * cos - py * sin,
			origin_y + px * sin + py * cos,
			rotation,
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
	-- lock facing to where the sweep started so it can't switch sides mid-sweep
	local attack = entity.sweep or entity.swing
	local facing_angle = attack and attack.start or entity.aim_rotation
	local flip_x = math.cos(facing_angle) < 0

	local facing = flip_x and -1 or 1
	local target_offset = facing * (entity.dimensions.width / 2 + 2)

	entity.held_item_offset_x = entity.held_item_offset_x or target_offset
	entity.held_item_offset_x = entity.held_item_offset_x
	+ (target_offset - entity.held_item_offset_x) * math.min(1, 12 * dt)

	local origin_x = entity.pos.x + entity.held_item_offset_x
	local origin_y = entity.pos.y - entity.dimensions.height * 0.3

	-- tilt back while a sweep is held, swing down on release, then ease back to rest
	local target_tilt = 0
	local tilt_speed = 12
	if entity.sweep then
		-- more sweep = more wind-up, from 10° up to 60° at max_sweep
		local ratio = math.min(math.abs(entity.sweep.angle) / math.rad(item.max_sweep), 0.2)
		target_tilt = facing * math.rad(10 + 50 * ratio)
	elseif entity.swing then
		target_tilt = -facing * math.rad(90)
		tilt_speed = 30
		entity.swing.time = entity.swing.time - dt
		if entity.swing.time <= 0 then
			entity.swing = nil
		end
	end
	entity.weapon_tilt = entity.weapon_tilt or 0
	entity.weapon_tilt = entity.weapon_tilt
	+ (target_tilt - entity.weapon_tilt) * math.min(1, tilt_speed * dt)

	self:draw_item_sprite(renderer, sprite, origin_x, origin_y, size, flip_x, entity.weapon_tilt)

	if entity.sweep then
		local radius = 14
		local steps = 8
		for i = 0, steps do
			local a = entity.sweep.start + entity.sweep.angle * (i / steps)
			renderer:create_shape(1, 1, entity.pos.x + math.cos(a) * radius, entity.pos.y + math.sin(a) * radius, a, {1, 0, 0, 0.6})
		end
	end
end

return DrawItems