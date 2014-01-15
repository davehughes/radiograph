File storage patterns:
----------------------
- original files stored as /[Genus] [species]/[institution]_[id]_[Genus]_[species]_[aspect].tif
- Proposed: store files in corresponding directories:
  - /[original path]/[original basename]/original.tif
  -      ''         /        ''         /compressed.png
  -      ''         /        ''         /medium.png
  -      ''         /        ''         /thumb.png


Image processing:
-----------------
+ Original images are ~7MB TIFFs at ~1800x1100 resolution
+ Derivatives, created using imagemagick's 'convert' utility:
  + Original size, PNG, compressed to ~850 KB/~12%
  + Medium, PNG, resized to fit within 800x800 resolution (~188KB)
  + Thumbnail, PNG, resized to fit within 120x120 resolution (~15KB)
