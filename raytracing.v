module main

import math
import kitty

const (
	aspect_ratio = f32(16.0) / 9.0
	image_width  = 400
	image_height = int(image_width / aspect_ratio)
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

fn (v Vec3) * (u Vec3) Vec3 {
	return Vec3{
		data: [v.x() * u.x(), v.y() * u.y(), v.z() * u.z()]!
	}
}

fn (v Vec3) scale(t f32) Vec3 {
	return Vec3{
		data: [v.x() * t, v.y() * t, v.z() * t]!
	}
}

fn (v Vec3) divide(t f32) Vec3 {
	return v.scale((f32(1.0) / t))
}

fn (v Vec3) len() f32 {
	return math.sqrtf(v.x() * v.x() + v.y() * v.y() + v.z() * v.z())
}

fn dot(v Vec3, u Vec3) f32 {
	return v.x() * u.x() + v.y() * u.y() + v.z() * u.z()
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

fn (v Vec3) normalize() Vec3 {
	return v.divide(v.len())
}

struct Ray {
pub:
	origin    Vec3
	direction Vec3
}

fn (r Ray) at(t f32) Vec3 {
	return r.origin + r.direction.scale(t)
}

fn (r Ray) hit_sphere(center Vec3, radius f32) bool {
	origin_center := r.origin - center
	a := dot(r.direction, r.direction)
	b := dot(origin_center, r.direction) * f32(2.0)
	c := dot(origin_center, origin_center) - radius * radius
	discriminant := b * b - (a * c) * f32(4.0)
	return discriminant > 0
}

fn (r Ray) color() Vec3 {
   	sphere := Vec3{
		   data:[f32(0),0,-1]!
	}
	if r.hit_sphere(sphere, f32(0.5)){
		return Vec3{data:[f32(1),0,0]!}
	}

	unit := r.direction.normalize()
	t := 0.5 * (unit.y() + 1.0)
	return Vec3{
		data: [f32(1), 1, 1]!
	}.scale(1.0 - t) + Vec3{
		// Background blue
		data: [f32(0.5), 0.7, 1.0]!
	}.scale(t)
}

fn write_color(mut buffer []byte, rgb Vec3) {
	buffer << byte(255.999 * rgb.x())
	buffer << byte(255.999 * rgb.y())
	buffer << byte(255.999 * rgb.z())
}

fn main() {
	// Camera
	viewport_height := f32(2.0)
	viewport_width := aspect_ratio * viewport_height
	focal_length := f32(1.0)
	origin := Vec3{
		data: [f32(0), 0, 0]!
	}
	horizontal := Vec3{
		data: [viewport_width, 0, 0]!
	}
	vertical := Vec3{
		data: [f32(0), viewport_height, 0]!
	}
	lower_left_corner := origin - horizontal.divide(2) - vertical.divide(2) - Vec3{
		data: [f32(0), 0, focal_length]!
	}
	// Render
	mut rgb_buffer := []byte{len: 0, cap: image_width * image_height}
	for j := image_height - 1; j >= 0; j-- {
		for i := 0; i < image_width; i++ {
		// for i in 0 .. image_width {
			// println('${i + j} / ${image_width + image_height}')

			// Baking UV pixels
			u := f32(i) / (image_width - 1)
			v := f32(j) / (image_height - 1)
			r := Ray{
				origin: origin
				direction: lower_left_corner + horizontal.scale(u) + vertical.scale(v) - origin
			}
			pixel_color := r.color()
			write_color(mut rgb_buffer, pixel_color)
		}
	}
	kitty.print_rgb_at_point(rgb_buffer, u32(image_width), u32(image_height))
}
