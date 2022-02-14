import img
import os

fn main() {
	mut decoder := img.new_png_decoder()
	fi := os.open("test.png") or {
		println(err)
		return
	}
	im := decoder.decode(fi) or {
		println("Decode error: ${err}")
		return
	}
	println(im)
}
