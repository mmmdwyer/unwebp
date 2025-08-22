unwebp.pl

This python script uses PIL and a few other tricks
to check if a WEBP file needs to be a lossless PNG,
a transparent PNG, or an animated PNG and converts
as needed. If none of these are required, it writes
a JPEG image.

WARNING
This deletes the original webp file, and the default
compression to JPEG is LOSSY, so you WILL lose data.


