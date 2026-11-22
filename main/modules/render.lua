local Renderer = {
	vertices = {}
}

local EntityType = require("main.modules.entity_type")
local ProjectileType = require("main.modules.projectile_type")

function Renderer:init(mesh_url)
	self.mesh_url = mesh_url
	self.vertex_resource = go.get(mesh_url, "vertices")
	self.max_vertices = 4096 * 6

	self.vertex_buffer = buffer.create(self.max_vertices, {
		{
			name = hash("position"),
			type = buffer.VALUE_TYPE_FLOAT32,
			count = 3
		},
		{
			name = hash("normal"),
			type = buffer.VALUE_TYPE_FLOAT32,
			count = 3
		},
		{
			name = hash("color"),
			type = buffer.VALUE_TYPE_FLOAT32,
			count = 4
		}
	})
	self.positions = buffer.get_stream(self.vertex_buffer, hash("position"))
	self.normals = buffer.get_stream(self.vertex_buffer, hash("normal"))
	self.colors = buffer.get_stream(self.vertex_buffer, hash("color"))

	for i = 1, self.max_vertices * 3, 3 do
		self.normals[i] = 0
		self.normals[i + 1] = 0
		self.normals[i + 2] = 1
	end

	resource.set_buffer(self.vertex_resource, self.vertex_buffer)
end

function Renderer:clear()
	self.vertices = {}
end

function Renderer:create_eyes(entity)
	local w = entity.dimensions.width
	local h = entity.dimensions.height

	local eye_area = 0.1
	local eye_h = h * 0.4
	local eye_w = (w * h * eye_area) / eye_h

	local spacing = w * 0.2

	-- how far the eyes can shift without leaving the body
	local max_offset_x = w / 2 - spacing - eye_w / 2
	local max_offset_y = h / 2 - eye_h / 2

	local offset_x = entity.look_dir.x * max_offset_x
	local offset_y = entity.look_dir.y * max_offset_y

	for _, side in ipairs({-1, 1}) do
		local eye_x = entity.pos.x + side * spacing + offset_x
		local eye_y = entity.pos.y + offset_y

		self:create_shape(eye_w, eye_h, eye_x, eye_y, 0, {0, 0, 0, 1})
	end
end

function Renderer:create_aim_indicator(entity)
	local distance = 14
	local size = 2
	local spread = 2
	local colour = {0, 181 / 255, 1, 0.7}

	local angle = entity.aim_rotation
	local forward_x = math.cos(angle)
	local forward_y = math.sin(angle)
	local perpendicular_x = -forward_y
	local perpendicular_y = forward_x

	local centre_x = entity.pos.x + forward_x * distance
	local centre_y = entity.pos.y + forward_y * distance

	self:create_shape(size, size, centre_x, centre_y, angle, colour)

	for _, side in ipairs({-1, 1}) do
		self:create_shape(
			size, size,
			centre_x - forward_x * spread + perpendicular_x * spread * side,
			centre_y - forward_y * spread + perpendicular_y * spread * side,
			angle, colour
		)
	end
end

function Renderer:create_shape(width, height, x, y, rotation, colour)
	local half_w = width / 2
	local half_h = height / 2

	local cos = math.cos(rotation)
	local sin = math.sin(rotation)

	local corners = {
		{-half_w, -half_h},
		{ half_w, -half_h},
		{ half_w,  half_h},
		{-half_w,  half_h}
	}

	local indices = {1, 2, 3, 1, 3, 4}

	for _, index in ipairs(indices) do
		local vertex = corners[index]

		local world_x = vertex[1] * cos - vertex[2] * sin + x
		local world_y = vertex[1] * sin + vertex[2] * cos + y

		table.insert(self.vertices, {
			position = {world_x, world_y, 0},
			colour = colour
		})
	end
end

function Renderer:flush()
	local vertex_count = #self.vertices

	if vertex_count > self.max_vertices then
		error("Renderer vertex capacity exceeded!")
	end

	for i, vertex in ipairs(self.vertices) do
		local position_offset = (i - 1) * 3
		local colour_offset = (i - 1) * 4

		self.positions[position_offset + 1] = vertex.position[1]
		self.positions[position_offset + 2] = vertex.position[2]
		self.positions[position_offset + 3] = vertex.position[3]

		self.colors[colour_offset + 1] = vertex.colour[1]
		self.colors[colour_offset + 2] = vertex.colour[2]
		self.colors[colour_offset + 3] = vertex.colour[3]
		self.colors[colour_offset + 4] = vertex.colour[4]
	end

	for i = vertex_count * 3 + 1, self.max_vertices * 3 do
		self.positions[i] = 0
	end

	resource.set_buffer(self.vertex_resource, self.vertex_buffer)
end

return Renderer