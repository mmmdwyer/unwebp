#!/usr/bin/python3

# python3-pil
import PIL.Image
import PIL  # Pillow, Python Image Library. pythone3-pil
import io   # for BytesIO
import os   # for os.scandir


for entry in os.scandir('.'):
	if entry.name.endswith('.webp') and entry.is_file():
		# Open the image file
		try:
			image = PIL.Image.open(entry.name)
		except:
			print(f'Could not open file: {entry.name}')
			continue

		filename = image.filename
		print(f'-- Inspecting {filename}')
		if image.format != "WEBP":
			print(f'File is {image.format}, not a WEBP file: {filename}')
			continue
		# Collecting some assorted info
		exif = image.getexif()
		dimensions = f'{image.width}x{image.height}'
		webplength = os.stat(filename).st_size
		rawlength = len(image.tobytes())

		# Set flags
		force_png = False

		# Try out PNG encoding
		pngversion = io.BytesIO()
		with open(filename, "rb") as fp:
			if fp.read(15)[-1:] == b"L":
				# VP8L means lossless. Look for that L
				print("*** Lossless detected. Forcing PNG.")
				image.save(pngversion, 'PNG', save_all=True)
				force_png = True
		if image.n_frames > 1:
			print("*** Animation detected. Forcing PNG.")
			image.save(pngversion, 'PNG', save_all=True)
			force_png = True
		elif image.mode == 'RGBA':
			print("*** Alpha channel detected. Forcing PNG.")
			force_png = True
			image.save(pngversion, 'PNG')
		else:
			image.save(pngversion, 'PNG')
			force_png = True
		pnglength = len(pngversion.getbuffer())

		# At this point, I think we've selected PNG for any images
		# that have a hard requirement for it. What's left are 
		# almost certainly supposed to be JPEGs.

		# Try out JPG encoding
		jpglength = 0
		if not force_png:
			jpgversion = io.BytesIO()
			image.save(jpgversion, 'JPEG', exif=exif)
			jpglength = len(jpgversion.getbuffer())

		# Do some math to help the decision
		# I turned this off because I couldn't find any reasons 
		# aside from what I'd already found to go webp->png.
		#webppercent = (webplength * 100) / rawlength
		#jpegpercent = (jpglength * 100) / rawlength
		#pngpercent = (pnglength * 100) / rawlength
		#print(f'{image.width}x{image.height} rawlen:{rawlength} webp:{webplength}({webppercent:.0f})  jpg:{jpglength}({jpegpercent:.0f}) png:{pnglength}({pngpercent:.0f})  {image.filename}')
		#print(f'   jpgdiff:{jpegpercent-webppercent:.1f}')
		#print(f'   pngdiff:{pngpercent-webppercent:.1f}')
		#if (pngpercent-webppercent) < 10 :
		#	print("*********")

