#!/bin/bash

set -euo pipefail

echo "Starting Ubuntu system cleanup and optimization..."

# Ensure the script runs as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root (e.g., using sudo)."
    exit 1
fi

# Function to log and run commands
run() {
    echo "Executing: $*"
    $@
}

# 1. Update and upgrade the system
echo "Updating and upgrading system packages..."
run apt update -y
run apt upgrade -y

# 2. Clean up unnecessary packages and dependencies
echo "Cleaning up unnecessary packages..."
run apt autoremove -y
run apt autoclean -y
run apt clean -y

# 3. Remove temporary files
echo "Removing temporary files..."
run rm -rf /tmp/*
run rm -rf /var/tmp/*

# 4. Clear user cache
echo "Clearing user cache..."
rm -rf /home/*/.cache/* || true
rm -rf /root/.cache/* || true

# 5. Clear system logs
echo "Truncating system log files..."
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# 6. Remove old kernels
echo "Removing old kernels (except the current one)..."
run apt purge -y $(dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-[0-9]' | grep -v "$(uname -r)")

# 7. Clear Snap package cache
echo "Cleaning unused Snap revisions..."
snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
    run snap remove "$snapname" --revision="$revision"
done

# 8. Optimize swap usage
echo "Refreshing swap space..."
run swapoff -a
run swapon -a

# 9. Disable unnecessary services (optional)
echo "Disabling unnecessary services..."
run systemctl disable cups 2>/dev/null || true  # Disable printer service if not used
run systemctl disable bluetooth 2>/dev/null || true  # Disable Bluetooth if not used

# 10. Clear thumbnail cache
echo "Clearing thumbnail cache..."
rm -rf /home/*/.cache/thumbnails/* || true

# Final message
echo "System cleanup and optimization complete!"
echo "For maximum effect, consider rebooting the system."
