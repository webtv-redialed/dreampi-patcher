#!/bin/bash
# 2026 WebTV Redialed

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Please run with root privileges."
    exit
fi

function Help() {
cat <<EOD
Usage: $0 <dreampi.img>
Adds WebTV Redialed's modifications to DreamPi.

Special thanks to the DreamPi team!
EOD
}

if [[ ! $1 ]]; then
    Help
    exit 0
elif [[ ! -e "$1" ]]; then
    echo "Huh? I can't seem to find '"$1"'"
    exit 1
fi

linux_start_sector=$(fdisk -l "$1" | grep Linux | awk '{print $2}')
sector_size=$(fdisk -l "$1" | grep "Units: sectors" | awk '{print $8}')
offset=$(($linux_start_sector * $sector_size))
mount_point="/mnt/dreampi"
compress_image=true

echo "Linux partition found at "$offset""

if [[ ! -d "$mount_point" ]]; then
    echo "Mount point not found, creating one at '"$mount_point"'"
    sudo mkdir "$mount_point"
fi

echo "Mounting image"
sudo mount -o loop,offset="$offset" "$1" "$mount_point"

if [ -z "$( ls -A "$mount_point" )" ]; then
    echo "Something's not right, '"$mount_point"' is empty."
    exit 1
fi

echo "Copying files"
cp -r "redialed_root/." "$mount_point/"

echo "Unmounting image"
sudo umount "$mount_point"

if [[ $compress_image = true ]]; then
    img=""$1"_webtv_$(date +%F).tar.gz"
    echo "Compressing image to '"$img"'"
    tar -czf "$img" "$1"
fi