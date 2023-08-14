#!/bin/bash

#cd /tmp
#time aria2c  -x16 -s50
#time tar xf ccache.tar.gz

mkdir -p ~/ci
cd ~/ci
repo init --depth=1 https://github.com/LineageOS/android.git -b lineage-20.0 --git-lfs
git clone -b https://github.com/nem1xer/local_manifests/blob/lineage-20.0-sea/local_manifest.xml .repo/local_manifests
repo sync -j4 --force-sync --optimized-fetch --no-tags --no-clone-bundle --prune


cd ~/ci
. build/envsetup.sh
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 100G
ccache -o compression=true
ccache -z
sh sea_patches/apply.sh
lunch lineage_sea-userdebug
mka hiddenapi-lists-docs && mka system-api-stubs-docs && mka test-api-stubs-docs
mka init
m bacon -j8 & sleep 75m

cache() {
cd /tmp
rm ccache.tar.gz
com ()
{
    tar --use-compress-program="pigz -k -$2 " -cf ccache.tar.gz ccache
}

cd /tmp
sudo apt install jq -y
rm ccache.tar.gz
time com ccache 1
wget https://github.com/Sushrut1101/GoFile-Upload/raw/master/upload.sh >> /dev/null
chmod +x upload.sh
./upload.sh ccache.tar.gz
}
cache