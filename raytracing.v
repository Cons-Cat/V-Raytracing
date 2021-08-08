module main

import math
import kitty
import time

const (
	aspect_ratio = f32(16.0) / 9.0
	image_width  = 400
	image_height = int(image_width / aspect_ratio)
	infinity     = f32(math.inf(1))
)

struct Camera {
	origin            Vec3
	lower_left_corner Vec3
	horizontal        Vec3
	vertical          Vec3
	focal_length      f32
}

fn make_camera() Camera {
	viewport_height := f32(2.0)
	viewport_width := aspect_ratio * viewport_height
	origin := make_vec(f32(0), 0, 0)
	horizontal := make_vec(viewport_width, 0, 0)
	vertical := make_vec(f32(0), -viewport_height, 0)
	focal_length := f32(1.0)
	camera := Camera{
		focal_length: focal_length
		origin: origin
		horizontal: horizontal
		vertical: vertical
		lower_left_corner: origin - horizontal.divide(2) - vertical.divide(2) - make_vec(f32(0),
			0, focal_length)
	}

	return camera
}

struct Vec3 {
mut:
	data [3]f32
}

fn make_vec(x f32, y f32, z f32) Vec3 {
	return Vec3{
		data: [x, y, z]!
	}
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
	return make_vec(v.x() + u.x(), v.y() + u.y(), v.z() + u.z())
}

fn (v Vec3) - (u Vec3) Vec3 {
	return make_vec(v.x() - u.x(), v.y() - u.y(), v.z() - u.z())
}

fn (v Vec3) * (u Vec3) Vec3 {
	return make_vec(v.x() * u.x(), v.y() * u.y(), v.z() * u.z())
}

fn (v Vec3) scale(t f32) Vec3 {
	return make_vec(v.x() * t, v.y() * t, v.z() * t)
}

fn (v Vec3) divide(t f32) Vec3 {
	return v.scale((f32(1.0) / t))
}

fn (v Vec3) reverse() Vec3 {
	return make_vec(-v.x(), -v.y(), -v.z())
}

fn (v Vec3) len_squared() f32 {
	return v.x() * v.x() + v.y() * v.y() + v.z() * v.z()
}

fn (v Vec3) len() f32 {
	return math.sqrtf(v.len_squared())
}

fn dot(v Vec3, u Vec3) f32 {
	return v.x() * u.x() + v.y() * u.y() + v.z() * u.z()
}

fn cross(v Vec3, u Vec3) Vec3 {
	return make_vec(u.y() * v.z() - u.z() * v.y(), u.z() * v.x() - u.x() * v.z(), u.x() * v.y() - u.y() * v.x())
}

fn (v Vec3) normalize() Vec3 {
	return v.divide(v.len())
}

struct Ray {
pub:
	origin    Vec3
	direction Vec3
}

fn make_ray(ori Vec3, dir Vec3) Ray {
	return Ray{
		origin: ori
		direction: dir
	}
}

fn (r Ray) at(t f32) Vec3 {
	return r.origin + r.direction.scale(t)
}

fn (r Ray) color(hittable &Hittable) Vec3 {
	mut hit_record := HitRecord{}
	if hittable.hit(r, 0, infinity, mut hit_record) {
		return (hit_record.normal + make_vec(f32(1), 1, 1)).divide(2)
	}

	// Make a background gradient
	unit := r.direction.normalize()
	t := (unit.y() + 1) / 2
	return make_vec(f32(1), 1, 1).scale(1 - t) + // Background blue
	make_vec(f32(0.5), 0.7, 1.0).scale(t)
}

struct HitRecord {
pub mut:
	point        Vec3
	normal       Vec3
	t            f32
	facing_front bool
}

// TODO: When a V bug in fixed, outward_normal should be &Vec3
fn (mut hr HitRecord) set_face_normal(ray &Ray, outward_normal Vec3) {
	facing_front := dot(ray.direction, outward_normal) < 0
	hr.normal = if facing_front { outward_normal } else { outward_normal.reverse() }
}

interface Hittable {
	hit(ray &Ray, t_min f32, t_max f32, mut hit_record HitRecord) bool
}

struct Sphere {
	center Vec3
	radius f32
}

fn make_sphere(center Vec3, radius f32) Sphere {
	return Sphere{
		center: center
		radius: radius
	}
}

fn (s Sphere) hit(ray &Ray, t_min f32, t_max f32, mut hit_record HitRecord) bool {
	origin_center := ray.origin - s.center
	a := ray.direction.len_squared()
	half_b := dot(origin_center, ray.direction)
	c := origin_center.len_squared() - s.radius * s.radius
	discriminant := half_b * half_b - a * c
	// If the discriminant is negative, this quadratic is unsolvable.
	if discriminant < 0 {
		return false
	}
	discriminant_sqrt := math.sqrtf(discriminant)
	nearest_sqrt_minus := (-half_b - discriminant_sqrt) / a
	// If the distance to this intersection is within bounds
	if nearest_sqrt_minus < t_min || t_max < nearest_sqrt_minus {
		nearest_sqrt_plus := (-half_b + discriminant_sqrt) / a
		if nearest_sqrt_plus < t_min || t_max < nearest_sqrt_plus {
			return false
		}
	}
	hit_record.t = nearest_sqrt_minus
	hit_record.point = ray.at(nearest_sqrt_minus)
	outward_normal := (hit_record.point - s.center).divide(s.radius)
	hit_record.set_face_normal(ray, outward_normal)
	return true
}

struct HittableList {
mut:
	hittables []&Hittable
}

fn (hl HittableList) hit(ray &Ray, t_min f32, t_max f32, mut hit_record HitRecord) bool {
	mut temp_record := HitRecord{}
	mut hit_anything := false
	mut closest_so_far := t_max
	for hittable in hl.hittables {
		if hittable.hit(ray, t_min, closest_so_far, mut temp_record) {
			hit_anything = true
			closest_so_far = temp_record.t
			hit_record = temp_record
		}
	}
	return hit_anything
}

fn write_color(i int, shared rgb_buffer []byte, rgb Vec3) {
    rgb_buffer[i] = byte(255.999 * rgb.x())
    rgb_buffer[i+1] = byte(255.999 * rgb.y())
    rgb_buffer[i+2] = byte(255.999 * rgb.z())
}

fn ray_task(camera Camera, image_width f32, image_height f32, x int, y int, world HittableList, shared rgb_buffer []byte) {
	// Baking UV pixels
	u := f32(x) / (image_width - 1)
	v := f32(y) / (image_height - 1)
	r := make_ray(camera.origin, camera.lower_left_corner + camera.horizontal.scale(u) +
		camera.vertical.scale(v) - camera.origin)
	pixel_color := r.color(world)
	write_color((int(x) + int(y * image_width))*3, shared rgb_buffer, pixel_color)
}

fn main() {
	// World
	mut world := HittableList{}
	world.hittables << &Hittable(make_sphere(make_vec(f32(0), 0, -1), 0.5))
	world.hittables << &Hittable(make_sphere(make_vec(f32(0), -100.5, -1), 100))
	// Camera
	camera := make_camera()
	// Rendering
	timer := time.new_stopwatch()
	// This cap initilization does not work correctly with TCC, but it does for Clang and GCC.
	shared rgb_buffer := []byte{len: image_width * image_height*3}
	for j := image_height - 1; j >= 0; j-- {
		for i := 0; i < image_width; i++ {
			// This can be parallellized by the 'go' keyword.
			ray_task(camera, image_width, image_height, i, j, world, shared rgb_buffer)
		}
	}
	time := timer.elapsed().milliseconds()
	rlock rgb_buffer{
		kitty.print_rgb_at_point(rgb_buffer, image_width, image_height)
	}
	println('\nImage rendered in $time ms')
}
