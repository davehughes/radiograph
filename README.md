Quickstart:
-----------
Requirements: docker, docker-compose
```
apt install -y docker-compose
git clone <this repo>
docker-compose up
```

```
# Install Docker
# https://docs.docker.com/install/linux/docker-ce/ubuntu/
sudo apt-get update

sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt update
sudo apt install -y docker-ce

# Install software in this repo
cd /opt
sudo git clone https://github.com/davehughes/radiograph
cd radiograph
sudo apt install -y virtualenv python2.7
sudo virtualenv env
sudo env/bin/pip install docker-compose
# Edit docker-compose.yml to add secrets/config as appropriate
# Download database backup to root directory, named 'radiograph-backup.sql'
sudo env/bin/docker-compose build
sudo env/bin/docker-compose up -d
```

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
