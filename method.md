
== Image generation ==

Image derivatives were generated from the original TIFFs by running the
process_images() function in radiograph/scripts/generate_images.py as of
commit bfba2b70cda992e1e73c08c0fb65a5386e7670b7 (this script will need to be
superficially changed to run in a different context, since it hard-codes the
x-ray input and output root directories.

Images were generated using ImageMagick version 6.8.7-0.  The output images are
in PNG format and represent three sizes:
+ Full size, matching the resolution of the original TIFFs
+ 'Medium', an 800x800 derivative generated from the original TIFF
+ 'Thumbnail', a 150x150 derivative generated from the original TIFF, and
  intended for small image previews
