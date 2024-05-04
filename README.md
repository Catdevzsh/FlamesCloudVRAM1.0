#!/bin/bash

# Requires root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Ask user for the folder to use for operations
read -p "Please enter the directory path for VRAM and disk operations: " USER_DEFINED_PATH

# Validate that the directory exists
if [ -d "$USER_DEFINED_PATH" ]; then
    echo "Using $USER_DEFINED_PATH for all operations."
else
    echo "Directory does not exist. Please check the path and try again."
    exit 1
fi

echo "Listing all mounted hard drives on the system:"
# List all mounted volumes and their device identifiers
diskutil list

# Set the user defined path as the default for VRAM and hard disk operations
export DEFAULT_STORAGE_PATH="$USER_DEFINED_PATH"

# Set up RAM disk (adjust size as needed)
ramfs_size_mb=2048  # 2GB RAM disk size
mount_point="/mnt/ramdisk"
mkdir -p $mount_point
mount -t ramfs -o size=$((ramfs_size_mb * 1024))k ramfs $mount_point
echo "RAM disk set up at $mount_point with size $ramfs_size_mb MB."

# Set up VRAM (assumed to be a GPU's VRAM)
vram_size_mb=1024  # 1GB VRAM size
vram_mount_point="/mnt/vram"
mkdir -p $vram_mount_point
mount -t tmpfs -o size=$((vram_size_mb * 1024))k tmpfs $vram_mount_point
echo "VRAM set up at $vram_mount_point with size $vram_size_mb MB."

# Set up SSD/default hard disk (assumed to be a physical disk or SSD)
# Assuming the user defined path is used as the default SSD/hard disk
ssd_mount_point="/mnt/ssd"
mkdir -p $ssd_mount_point
mount --bind $USER_DEFINED_PATH $ssd_mount_point
echo "SSD/default hard disk set up at $ssd_mount_point."
