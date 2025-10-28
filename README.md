unwebp.pl

This python script uses PIL and a few other tricks
to check if a WEBP or AVIF file needs to be converted
to a lossless PNG, a transparent PNG, or an animated
PNG and converts as needed. If none of these are
required, it writes a JPEG image.

AVIF support requires a more current version of PIL
than Ubuntu delivers. You can force a local install
of a newer PIL via pip like so:

  pip3 install pillow --ignore-installed

WARNING
This deletes the original file, and the default
compression to JPEG is LOSSY, so you WILL lose data.

The AVIF code doesn't understand lossless AVIF files,
so it WILL degrade these to lossy JPGs. Again, you
WILL lose data.


