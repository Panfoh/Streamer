#!/bin/bash

echo "Starting system cleanup and optimization..."

# Function to run commands with sudo and handle errors
run_with_sudo() {
    if ! sudo $1; then
        echo "Error executing: $1"
        exit 1
    fi
}

# 1. Update the package lists and upgrade installed packages
echo "Updating and upgrading system packages..."
run_with_sudo "apt update -y && apt upgrade -y"

# 2. Remove unnecessary packages and dependencies
echo "Removing unnecessary packages..."
run_with_sudo "apt autoremove -y && apt autoclean -y"

# 3. Clean apt cache
echo "Cleaning up APT cache..."
run_with_sudo "apt clean"

# 4. Remove temporary files
echo "Removing temporary files..."
run_with_sudo "rm -rf /tmp/*"
run_with_sudo "rm -rf /var/tmp/*"

# 5. Clear system logs (optional, be cautious)
echo "Clearing system logs..."
run_with_sudo "find /var/log -type f -name '*.log' -exec truncate -s 0 {} \;"

# 6. Clear user cache
echo "Clearing user cache..."
rm -rf ~/.cache/*

# 7. Clear old kernels (be cautious with this step!)
echo "Removing old kernels..."
run_with_sudo "dpkg --list | grep 'linux-image' | awk '{ print $2 }' | grep -v $(uname -r) | xargs sudo apt purge -y"

# 8. Optimize swap usage
echo "Optimizing swap usage..."
run_with_sudo "swapoff -a && swapon -a"

# 9. Disable unnecessary startup services (optional)
echo "Disabling unnecessary startup services..."
run_with_sudo "systemctl disable cups" # Example: Disable printer services
run_with_sudo "systemctl disable bluetooth" # Disable Bluetooth if not used

# 10. Remove orphaned packages
echo "Removing orphaned packages..."
run_with_sudo "deborphan | xargs sudo apt purge -y"

# 11. Free up disk space from unused Snap packages
echo "Cleaning unused Snap packages..."
run_with_sudo "snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do sudo snap remove $snapname --revision=$revision; done"

# 12. Clear DNS cache
echo "Clearing DNS cache..."
run_with_sudo "systemd-resolve --flush-caches"

# 13. Clear thumbnails cache
echo "Clearing thumbnails cache..."
rm -rf ~/.cache/thumbnails/*

# 14. Reboot suggestion
echo "Cleanup completed! For full effect, consider rebooting your system."

# Done
echo "System cleanup and optimization complete!"

