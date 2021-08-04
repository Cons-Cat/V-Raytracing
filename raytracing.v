module main

import kitty

const (
	image_width  = 256
	image_height = 256
)

fn main() {
	mut rgb_buffer := []byte{len: 0, cap: image_width * image_height}
	for i in 0 .. image_width {
		for j in 0 .. image_height {
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
	kitty.print_rgb_at_point(rgb_buffer, image_width, image_height)
}
