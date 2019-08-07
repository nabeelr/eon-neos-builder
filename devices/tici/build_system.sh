#!/bin/bash -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
OUT=$DIR/out
ROOT=$DIR/../..
TOOLS=$ROOT/tools

cd $DIR
mkdir -p $OUT

$TOOLS/simg2img $DIR/android/out/target/product/sdm845/system.img system.img.raw
mkdir -p mnt
sudo mount -o loop system.img.raw mnt
sudo mkdir -p mnt/system/comma
sudo cp -R ../eon/build_usr/out/data/data/com.termux/files/usr mnt/system/comma
sudo cp -Rv "$DIR/../eon/home" mnt/system/comma/home
sudo chmod 600 mnt/system/comma/home/.ssh/*
sudo chmod 600 -R mnt/system/comma/usr/etc/ssh
sudo ln -s /system/bin mnt/bin

# ramdisk is now here
sudo cp -v "$DIR"/ramdisk_common/* mnt/.
sudo sh -c 'echo -e "\nimport /init.comma.rc" >> mnt/init.rc'

sudo mkdir mnt/tmp
sudo umount mnt
mv system.img.raw $OUT/system.img
$TOOLS/img2simg $OUT/system.img $OUT/system.simg

# Clean up
rm -rf mnt

# Print output message
GREEN="\033[0;32m"
NO_COLOR='\033[0m'
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
echo -e "${GREEN}Output: ${BOLD}$OUT/system.img${NORMAL}${NO_COLOR}"

