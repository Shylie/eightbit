from PIL import Image

import argparse

def mif(data_in, file_out):
	file_out.write('WIDTH=8;\n')
	file_out.write(f'DEPTH={len(data_in)};\n')

	file_out.write('ADDRESS_RADIX=UNS;\nDATA_RADIX=UNS;\nCONTENT BEGIN\n')
	
	address = 0
	for data in data_in:
		file_out.write(f'\t{address} : {255 - data};\n')
		address = address + 1

	file_out.write('END;')

def main():
	parser = argparse.ArgumentParser(prog='convert_image', description='converts images to formats for fpga')
	parser.add_argument('filename')
	parser.add_argument('-p', default=256, type=int, required=False, help='Palette size')

	args = parser.parse_args()
	im = Image.open(args.filename).resize((160, 120)).quantize(args.p)
	with open('out.mif', 'w') as f:
		mif(im.getdata(), f)

if __name__ == '__main__':
	main()
