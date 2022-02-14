module img

import io

struct PNGDecoder {}

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

pub fn(d &PNGDecoder) decode(mut r io.Reader) ?Image {
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

fn (d &PNGDecoder)process_png_chunk(mut r io.Reader) ?bool {
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

fn (d &PNGDecoder) process_chunk(mut r io.Reader, length u32, chunk_type PNGChunkType) ?bool {
	match chunk_type {
		.header{ println("HEADER") }
		.palette{ println("PALETTE") }
		.image_data{ println("IMAGE DATA") }
		.image_end{ println("IMAGE END") }
		.chroma{ println("CHROMA")}
		.gamma{println("GAMMA")}
		.embedded_icc_profile{println("ICC PROFILE")}
		.significant_bits{ println("SIG BITS")}
		.standard_rgb{println("SRGB")}
		.background_color{println("BGCOLOR")}
		.histogram{println("HIST")}
		.physical_dimensions{println("PHYSICAL DIMS")}
		.suggested_palette{println("SUGGESTED PALETTE")}
		.time{println("TIME")}
		.international_text_data{println("INTNL TEXT DATA")}
		.text_data{println("TEXT")}
		.compressed_text{println("CMPRSD TEXT")}
	}

	mut bsdata := []byte{len: int(length) + 4}
	n_r := r.read(mut bsdata)?
	if n_r != length + 4 {
		return error("Failed reading chunk data")
	}

	return chunk_type == PNGChunkType.image_end
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
	return &PNGDecoder{}
}

