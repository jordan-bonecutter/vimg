module img

import gx

fn (im Image) op_safe(x u32, y u32) bool {
	return x < im.width && y < im.height
}

// Access the pixel at the given position
// Doesn't check for out-of-bounds! Use SafeAt
pub fn(im Image) at(x u32, y u32) []byte {
	mut start := int(0)
	mut stride := int(0)
	match im.pix_type {
		.rgb, .bgr {
			start = int(x + y*im.width)*3
			stride = 3
		}
		.rgba, .bgra {
			start = int(x + y*im.width)*4
			stride = 4
		}
		.v {
			start = int(x + y*im.width)
			stride = 1
		}
		.va {
			start = int(x + y*im.width)*2
			stride = 2
		}
	}

	return im.buffer[start..start+stride]
}

// Return the data at the coordinates or an error if they're oob
pub fn(im Image) safe_at(x u32, y u32) ?[]byte {
	if im.op_safe(x, y) {
		return im.at(x, y)
	}
	return error("Out of bounds!")
}

pub fn(im Image) color_at(x u32, y u32) gx.Color {
	data := im.at(x, y)
	match im.pix_type {
		.rgb {
			return gx.Color{r: data[0], g: data[1], b: data[2], a: 255}
		}
		.bgr {
			return gx.Color{r: data[2], g: data[1], b: data[0], a: 255}
		}
		.rgba {
			return gx.Color{r: data[0], g: data[1], b: data[2], a: data[3]}
		}
		.bgra {
			return gx.Color{r: data[2], g: data[1], b: data[0], a: data[3]}
		}
		.v {
			return gx.Color{r: data[0], g: data[0], b: data[0] a: 255}
		}
		.va {
			return gx.Color{r: data[0], g: data[0], b: data[0], a: data[1]}
		}
	}
}

pub fn(im Image) safe_color_at(x u32, y u32) ?gx.Color {
	if im.op_safe(x, y) {
		return im.color_at(x, y)
	}
	return error("Out of bounds!")
}

pub fn(mut im Image) set(x u32, y u32, color gx.Color) {
	match im.pix_type {
		.rgb {
			start := (x + y*im.width)*3
			im.buffer[start] = color.r
			im.buffer[start+1] = color.g
			im.buffer[start+2] = color.b
		}
		.rgba {
			start := (x + y*im.width)*4
			im.buffer[start] = color.r
			im.buffer[start+1] = color.g
			im.buffer[start+2] = color.b
			im.buffer[start+3] = color.a
		}
		.bgr {
			start := (x + y*im.width)*3
			im.buffer[start] = color.b
			im.buffer[start+1] = color.g
			im.buffer[start+2] = color.r
		}
		.bgra {
			start := (x + y*im.width)*4
			im.buffer[start] = color.b
			im.buffer[start+1] = color.g
			im.buffer[start+2] = color.r
			im.buffer[start+3] = color.a
		}
		.v {
			start := (x + y*im.width)
			im.buffer[start] = byte((int(color.r) + int(color.g) + int(color.b)) / 3)
		}
		.va {
			start := (x + y*im.width)*2
			im.buffer[start] = byte((int(color.r) + int(color.g) + int(color.b)) / 3)
			im.buffer[start+1] = color.a
		}
	}
}

pub fn(mut im Image) safe_set(x u32, y u32, color gx.Color) ? {
	if im.op_safe(x, y) {
		im.set(x, y, color)
		return
	}
	return error("Out of bounds!")
}

