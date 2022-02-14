module img

import io

// In memory pixel layout
pub enum PixType {
	v     // Single Value (black and white)
	va    // Black and white with alpha
	rgb   // Red green blue
	rgba  // Red green blue alpha
	bgr   // Blue green red
	bgra  // Blue green red alpha
}

pub fn stride(t PixType) int {
	match t {
		.v { return 1 }
		.va { return 2 }
		.rgb { return 3 }
		.rgba { return 4 }
		.bgr { return 3 }
		.bgra { return 4 }
	}
}

// An 8 bit color depth image
pub struct Image {
	pub:
	width  u32
	height u32
	pix_type PixType
	mut:
	buffer []byte
}

// Encodes an image
pub interface Encoder {
	encode(Image, mut io.Writer) ?int
}

// Decodes an image
pub interface Decoder {
	decode(mut r io.Reader) ?Image
}

