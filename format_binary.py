import argparse

def main():
	parser = argparse.ArgumentParser(
		prog = 'format_binary',
		description = 'converts a binary file into .mif format',
	)

	parser.add_argument('input')
	parser.add_argument('output')
	parser.add_argument('--width', required = True, type = int)
	parser.add_argument('--depth', required = True, type = int)

	args = parser.parse_args()

	with open(args.input, 'rb') as input_file:
		with open(args.output, 'w') as output_file:
			output_file.write(f'WIDTH={args.width};\n')
			output_file.write(f'DEPTH={args.depth};\n')
			output_file.write('ADDRESS_RADIX=HEX;\n')
			output_file.write('DATA_RADIX=HEX;\n')
			output_file.write('CONTENT BEGIN\n')

			for address in range(args.depth):
				bytestring = input_file.read(args.width // 8)
				val = None
				if bytestring != b'':
					val = int.from_bytes(bytestring)
				else:
					val = 0
				output_file.write(f'\t{address:X} : {int(val):X};\n')

			output_file.write('END;')

if __name__ == '__main__':
	main()
