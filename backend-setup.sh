#!/bin/bash
# Irunor backend rescue setup — run from Hetzner rescue mode
set -e
echo "=== Finding disk ==="
DISK=$(lsblk -rno NAME,TYPE | awk '$2=="disk"{print $1;exit}')
PART="/dev/${DISK}1"
echo "Mounting $PART"
mkdir -p /mnt/real
mount "$PART" /mnt/real

echo "=== Adding deploy SSH key ==="
mkdir -p /mnt/real/root/.ssh
chmod 700 /mnt/real/root/.ssh
PUBKEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPtyqDIMuK0aOzV4McJluTQendVVCtZB6hAZP2Kfd83N lark-autodeploy@irunor"
grep -qF "$PUBKEY" /mnt/real/root/.ssh/authorized_keys 2>/dev/null || echo "$PUBKEY" >> /mnt/real/root/.ssh/authorized_keys
chmod 600 /mnt/real/root/.ssh/authorized_keys

echo "=== Writing env vars ==="
ENV=/mnt/real/root/Irunor-2.0-backend-/.env
touch "$ENV"
grep -q "^VAULT_ENCRYPTION_KEY=" "$ENV" && sed -i "s|^VAULT_ENCRYPTION_KEY=.*|VAULT_ENCRYPTION_KEY=9BIwSz4J2swVYDztuLQlBTmOFgsbP0itGih7kOmeTOw=|" "$ENV" || echo "VAULT_ENCRYPTION_KEY=9BIwSz4J2swVYDztuLQlBTmOFgsbP0itGih7kOmeTOw=" >> "$ENV"
grep -q "^AGI_WORKER_SECRET=" "$ENV" && sed -i "s|^AGI_WORKER_SECRET=.*|AGI_WORKER_SECRET=9MrhoY4tZHZircbHLQPTuKsZ64FpkVRq|" "$ENV" || echo "AGI_WORKER_SECRET=9MrhoY4tZHZircbHLQPTuKsZ64FpkVRq" >> "$ENV"
grep -q "^BLOCK_EMAILS_UNTIL=" "$ENV" && sed -i "s|^BLOCK_EMAILS_UNTIL=.*|BLOCK_EMAILS_UNTIL=07:00|" "$ENV" || echo "BLOCK_EMAILS_UNTIL=07:00" >> "$ENV"

echo "=== Done — unmounting and rebooting ==="
umount /mnt/real && reboot
