module main

import math
import kitty

const (
	image_width  = 256
	image_height = 256
)

struct Vec3 {
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

fn (va Vec3) + (vb Vec3) Vec3 {
	return Vec3{
		x: va.x() + vb.x()
		y: va.y() + vb.y()
		z: va.z() + vb.z()
	}
}

fn (va Vec3) - (vb Vec3) Vec3 {
	return Vec3{
		x: va.x() - vb.x()
		y: va.y() - vb.y()
		z: va.z() - vb.z()
	}
}

fn (v Vec3) * (t f32) f32 {
	return Vec3{
		x: v.x() * t
		y: v.y() * t
		z: v.z() * t
	}
}

fn (v Vec3) / (t f32) f32 {
	return Vec3{
		x: v.x() / t
		y: v.y() / t
		z: v.z() / t
	}
}

fn (v Vec3) len() f32 {
   return math.sqrt(v.x()*v.x() + v.y()*v.y() + v.z()*v.z())
}

fn cross(v Vec3, u Vec3) Vec3 {
   return Vec3 {
   		 x: u.y() * v.z() - u.z() * v.y(),
		 y: u.z() * v.x() - u.x() * v.z(),
		 z: u.x() * v.y() - u.y() * v.x()
		  }
}

fn normalize(v Vec3) Vec3 {
   return v / v.len()
}

fn main() {
	mut rgb_buffer := []byte{len: 0, cap: image_width * image_height}
	for j in 0 .. image_width {
		for i in 0 .. image_height {
			red := f32(i) / (image_width - 1)
			green := f32(j) / (image_height - 1)
			blue := 0.25
			ir := byte(255.999 * red)
			ig := byte(255.999 * green)
			ib := byte(255.999 * blue)
			rgb_buffer << ir
			rgb_buffer << ig
			rgb_buffer << ib
		}
	}
	print_rgb_at_point(rgb_buffer, image_width, image_height)
}
