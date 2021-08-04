module main

import math
import kitty

const (
	image_width  = 256
	image_height = 256
)

struct Vec3 {
mut:
	data [3]f32
}

fn (v Vec3) x() f32 {
	return v.data[0]
}

fn (v Vec3) y() f32 {
	return v.data[1]
}

fn (v Vec3) z() f32 {
	return v.data[2]
}

fn (v Vec3) + (u Vec3) Vec3 {
	return Vec3{
		data: [
			v.x() + u.x(),
			v.y() + u.y(),
			v.z() + u.z(),
		]!
	}
}

fn (v Vec3) - (u Vec3) Vec3 {
	return Vec3{
		data: [
			v.x() - u.x(),
			v.y() - u.y(),
			v.z() - u.z(),
		]!
	}
}

fn (mut v Vec3) scale(t f32) {
	v.data = [v.x() * t, v.y() * t, v.z() * t]!
}

fn (mut v Vec3) divide(t f32) {
	v.data = [v.x() / t, v.y() / t, v.z() / t]!
}

fn (v Vec3) len() f32 {
	return math.sqrtf(v.x() * v.x() + v.y() * v.y() + v.z() * v.z())
}

fn cross(v Vec3, u Vec3) Vec3 {
	return Vec3{
		data: [
			u.y() * v.z() - u.z() * v.y(),
			u.z() * v.x() - u.x() * v.z(),
			u.x() * v.y() - u.y() * v.x(),
		]!
	}
}

fn normalize(v Vec3) Vec3 {
	mut new_vector := v
	new_vector.divide(v.len())
	return new_vector
}

fn write_color(mut buffer []byte, rgb Vec3) {
	red := f32(rgb.x()) / (image_width - 1)
	green := f32(rgb.y()) / (image_height - 1)
	blue := rgb.z()
	buffer << byte(255.999 * red)
	buffer << byte(255.999 * green)
	buffer << byte(255.999 * blue)
}

fn main() {
	mut rgb_buffer := []byte{len: 0, cap: image_width * image_height}
	for j in 0 .. image_width {
		for i in 0 .. image_height {
			write_color(mut rgb_buffer, Vec3{ data: [f32(i), j, 0.25]! })
		}
	}
	kitty.print_rgb_at_point(rgb_buffer, image_width, image_height)
}
