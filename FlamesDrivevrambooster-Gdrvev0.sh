#!/bin/bash

# Requires root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "Listing all mounted hard drives on the system:"
# List all mounted volumes and their device identifiers
diskutil list

# Assuming CloudMounter is installed and configured to mount
# the Flames Co. Database as a virtual drive
# Set CloudMounter directory as default for VRAM and hard disk operations
CLOUDMOUNTER_PATH="/Users/catdevzsh/Library/CloudStorage/CloudMounter-FlamesCo.Database/:home"

if [ -d "$CLOUDMOUNTER_PATH" ]; then
    echo "Setting $CLOUDMOUNTER_PATH as the default path for VRAM and disk operations."
    # Example of setting an environment variable or similar to use this path
    # This is a placeholder and might need adjustment based on actual use case
    export DEFAULT_STORAGE_PATH="$CLOUDMOUNTER_PATH"
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
    # Assuming the CloudMounter path is used as the default SSD/hard disk
    ssd_mount_point="/mnt/ssd"
    mkdir -p $ssd_mount_point
    mount --bind $CLOUDMOUNTER_PATH $ssd_mount_point
    echo "SSD/default hard disk set up at $ssd_mount_point."
    
else
    echo "CloudMounter path not found. Ensure CloudMounter is configured correctly."
fi

# Replace iCloud and all partitions on the macOS device with the configured storage
# WARNING: This will erase all data on the specified partitions!
echo "Replacing iCloud and all partitions with configured storage..."
diskutil eraseVolume JHFS+ "FlamesCo Storage" $(diskutil list | grep "Apple_APFS" | awk '{print $7}')
echo "Storage setup complete."
