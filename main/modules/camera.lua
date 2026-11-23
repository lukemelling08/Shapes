local DEFAULT_ZOOM = 3

local Camera = {
	x = 0,
	y = 0,
	default_zoom = DEFAULT_ZOOM,
	zoom = DEFAULT_ZOOM,
	target_zoom = DEFAULT_ZOOM,
	previous_frame_zoom = DEFAULT_ZOOM,
	rotation = 0,
	view_w = 640,
	view_h = 360,
	shake_time = 0,
	shake_duration = 0,
	shake_strength = 0
}

function Camera:shake(strength, duration)
	self.shake_strength = strength
	self.shake_duration = duration
	self.shake_time = duration
end

function Camera:move(x, y)
	self.x = self.x + x
	self.y = self.y + y
end

function Camera:set_pos(x, y)
	self.x = x
	self.y = y
end

function Camera:set_zoom(zoom)
	self.zoom = math.max(0.1, zoom)
end

function Camera:set_target_zoom(zoom)
	self.target_zoom = math.max(0.1, zoom)
end

function Camera:set_rotation(rotation)
	self.rotation = rotation
end

function Camera:screen_to_world(screen_x, screen_y)
	local width, height = window.get_size()

	local x = (screen_x / width) * 2 - 1
	local y = (screen_y / height) * 2 - 1

	return {
		x = self.x + x * width / 2,
		y = self.y + y * height / 2
	}
end

function Camera:update(dt)
	if self.target then
		local lerp = 5 * dt

		self.x = self.x + (self.target.pos.x - self.x) * lerp
		self.y = self.y + (self.target.pos.y - self.y) * lerp
		self.zoom = self.zoom + (self.target_zoom - self.zoom) * lerp
	end
	local width, height = window.get_size()

	self.view_w = self.view_h * (width / height)

	local view_w = self.view_w / self.zoom
	local view_h = self.view_h / self.zoom

	local shake_x, shake_y = 0, 0
	if self.shake_time > 0 then
		self.shake_time = self.shake_time - dt
		local s = self.shake_strength * (self.shake_time / self.shake_duration) -- fades out
		shake_x = (math.random() * 2 - 1) * s
		shake_y = (math.random() * 2 - 1) * s
	end

	go.set("/renderer#mesh", "cam",
		vmath.vector4(
			self.x + shake_x,
			self.y + shake_y,
			2 / view_w,
			2 / view_h
		)
	)
end

function Camera:follow(entity)
	self.target = entity
end

return Camera