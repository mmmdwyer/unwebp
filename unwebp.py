#!/usr/bin/python3

import io   # for BytesIO
import os   # for os.scandir
import PIL.Image
import PIL  # Pillow, Python Image Library. python3-pil


for entry in os.scandir('.'):
    if (entry.name.endswith('.webp') or entry.name.endswith('.avif')) and entry.is_file():
        # Open the image file
        try:
            image = PIL.Image.open(entry.name)
        except Exception:
            print(f'Could not open file: {entry.name}')
            continue

        print(f'-- Inspecting {image.filename}')
        if image.format != "WEBP" and image.format != 'AVIF':
            print(f'File is {image.format}, not a WEBP or AVIF file: {image.filename}')
            continue
        # Collecting some assorted info
        exif = image.getexif()

        # Set flags
        forcepng = False

        # Try out PNG encoding
        pngversion = io.BytesIO()
        # I'm not sure if AVIF has a lossless mode. There does exist
        # image.codec of aom, rav1e and svt, but that's not read in.
        if image.format == "WEBP":
            with open(image.filename, "rb") as fp:
                if fp.read(15)[-1:] == b"L":
                    # VP8L means lossless. Look for that L
                    print("*** Lossless PNG detected. Forcing PNG.")
                    image.save(pngversion, 'PNG', save_all=True)
                    forcepng = True
        if image.n_frames > 1:
            print("*** Animation detected. Forcing PNG.")
            image.save(pngversion, 'PNG', save_all=True)
            forcepng = True
        elif image.mode == 'RGBA':
            print("*** Alpha channel detected. Forcing PNG.")
            forcepng = True
            image.save(pngversion, 'PNG')

        # At this point, I think we've selected PNG for any images
        # that have a hard requirement for it. What's left are
        # almost certainly supposed to be JPEGs.
        if forcepng:
            outfilename = image.filename.removesuffix('.webp')+'.png'
            with open(outfilename, 'wb') as fp:
                fp.write(pngversion.getbuffer())
        else:
            outfilename = image.filename.removesuffix('.webp')+'.jpg'
            image.save(outfilename, 'JPEG', exif=exif)
        os.unlink(image.filename)
