module img

import io

enum PNGChunkType {
	header = 0x49484452
	palette = 0x504c5445
	image_data = 0x49444154
	image_end = 0x49454e44
	chroma = 0x6348524d
	gamma = 0x67414d41
	embedded_icc_profile = 0x69434350
	significant_bits = 0x73424954
	standard_rgb = 0x73524742
	background_color = 0x624b4744
	histogram = 0x68495354
	physical_dimensions = 0x70485973
	suggested_palette = 0x73504c54
	time = 0x74494d45
	international_text_data = 0x69545874
	text_data = 0x74455874
	compressed_text = 0x7a545874
}

enum PNGInterlaceMethod {
	no = 0
	adam7 = 1
}

struct PNGDecoder {
	mut:
	header_processed bool
	width u32
	height u32
	pix_type PixType
	interlace_method PNGInterlaceMethod
	ret Image
}

pub fn(mut d PNGDecoder) decode(mut r io.Reader) ?Image {
	mut header := []byte{len: 8}
	n_r := r.read(mut header) or {
		return error("Error occured while reading PNG stream: ${err}")
	}
	if n_r != 8 {
		return error("Couldn't read PNG header")
	}

	if !confirm_header(header) {
		return error("Not a PNG File")
	}

	for {
		done := d.process_png_chunk(r)?
		if done {
			break
		}
	}
	return error("Not implemented!")
}

fn (mut d PNGDecoder)process_png_chunk(mut r io.Reader) ?bool {
	mut chunk_header := []byte{len: 8}
	n_r := r.read(mut chunk_header) or {
		return error("Error occured while reading PNG stream: ${err}")
	}
	if n_r != 8 {
		return error("Error in PNG chunk")
	}

	length := (u32(chunk_header[0])<<24) | (u32(chunk_header[1])<<16) |
	          (u32(chunk_header[2])<<8) | (u32(chunk_header[3]))
	chunk_type := PNGChunkType((u32(chunk_header[4])<<24) | (u32(chunk_header[5])<<16) |
	          (u32(chunk_header[6])<<8) | (u32(chunk_header[7])))
	return d.process_chunk(r, length, chunk_type)
}

fn (mut d PNGDecoder) process_chunk(mut r io.Reader, length u32, chunk_type PNGChunkType) ?bool {
	mut chunk_data := []byte{len: int(length) + 4}
	r.read(mut chunk_data) or {
		return error("Error occured while reading PNG stream: ${err}")
	}

	if chunk_type != PNGChunkType.header && !d.header_processed {
		return error("Header chunk not found")
	}

	match chunk_type {
		.header{ return d.process_header(chunk_data) }
		.palette{ return d.process_palette(chunk_data) }
		.image_data{ return d.process_image_data(chunk_data) }
		.image_end{ return d.process_image_end(chunk_data) }
		.chroma{ return d.process_chroma(chunk_data) }
		.gamma{ return d.process_gamma(chunk_data) }
		.embedded_icc_profile{ return d.process_icc_profile(chunk_data) }
		.significant_bits{ return d.process_sig_bits(chunk_data) }
		.standard_rgb{ return d.process_srgb(chunk_data) }
		.background_color{ return d.process_background_color(chunk_data) }
		.histogram{ return d.process_hist(chunk_data) }
		.physical_dimensions{ return d.process_physical_dims(chunk_data) }
		.suggested_palette{ return d.process_suggested_palette(chunk_data) }
		.time{ return d.process_time(chunk_data) }
		.international_text_data{ return d.process_itext(chunk_data) }
		.text_data{ return d.process_text_data(chunk_data) }
		.compressed_text{ return d.process_compressed_text(chunk_data) }
	}
}

fn (mut d PNGDecoder) process_header(data []byte) ?bool {
	defer { d.header_processed = true }

	if data.len != 17 {
		return error("Error processing header: length must be 17 bytes!")
	}

	d.width = (u32(data[0])<<24) | (u32(data[1])<<16) |
						(u32(data[2])<<8) | (u32(data[3]))
	d.height = (u32(data[4])<<24) | (u32(data[5])<<16) |
						(u32(data[6])<<8) | (u32(data[7]))

	if data[8] != 8 {
		return error("Unsupported bit depth!")
	}

	match data[9] {
		0 {
			d.pix_type = PixType.v
		}
		2 {
			d.pix_type = PixType.rgb
		}
		3 {
			return error("Palettes are unsupported!")
		}
		4 {
			d.pix_type = PixType.va
		}
		6 {
			d.pix_type = PixType.rgba
		}
		else {
			return error("Unknown color type")
		}
	}

	d.interlace_method = PNGInterlaceMethod(data[12])

	d.ret = Image{
		width: d.width,
		height: d.height,
		pix_type: d.pix_type,
		buffer: []byte{len: int(d.width)*int(d.height)*stride(d.pix_type)},
	}

	return false
}

fn (mut d PNGDecoder) process_palette(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_image_data(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_image_end(data []byte) ?bool {
	return true
}

fn (mut d PNGDecoder) process_chroma(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_gamma(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_icc_profile(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_sig_bits(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_srgb(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_background_color(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_hist(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_physical_dims(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_suggested_palette(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_time(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_itext(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_text_data(data []byte) ?bool {
	return false
}

fn (mut d PNGDecoder) process_compressed_text(data []byte) ?bool {
	return false
}

fn confirm_header(header []byte) bool {
	if header.len != 8 {
		return false
	}

	return header[0] == 137 &&
	   header[1] == 80  &&
		 header[2] == 78  &&
		 header[3] == 71  &&
		 header[4] == 13  &&
		 header[5] == 10  &&
		 header[6] == 26  &&
		 header[7] == 10
}

pub fn new_png_decoder() Decoder {
	return &PNGDecoder{
		header_processed: false,
	}
}

