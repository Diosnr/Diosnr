#!/bin/bash
# Irunor AGI rescue setup — adds deploy SSH key, reboots to normal OS
# Anthropic API key is injected automatically by GitHub Actions on next push.
set -e
DISK=$(lsblk -rno NAME,TYPE | awk '$2=="disk"{print $1;exit}')
PART="/dev/${DISK}1"
echo "Mounting $PART..."
mkdir -p /mnt/real
mount "$PART" /mnt/real
mkdir -p /mnt/real/root/.ssh
chmod 700 /mnt/real/root/.ssh
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtyqDIMuK0aOzV4McJluTQendVVCtZB6hAZP2Kfd83N lark-autodeploy@irunor"
grep -qF "$PUBKEY" /mnt/real/root/.ssh/authorized_keys 2>/dev/null || echo "$PUBKEY" >> /mnt/real/root/.ssh/authorized_keys
chmod 600 /mnt/real/root/.ssh/authorized_keys
echo "SSH key added. Rebooting..."
umount /mnt/real && reboot
