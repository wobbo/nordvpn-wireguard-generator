#!/bin/bash

# 2026-01-21 12:43
# Ernst Lanser <ernst.lanser@wobbo.org> 
# https://forums.raspberrypi.com/viewtopic.php?t=395466#p2358920

# INSTALL WIREGUARD:
# sudo apt install wireguard-tools

# INSTALL NORDVPN:
# sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
# sudo usermod -aG nordvpn $USER
# sudo reboot
# nordvpn login

# DOWNLOAD AND EXECUTABLE THE SCRIPT:
# wget https://wobbo.org/install/2026-01-21/nordvpn-wireguard.sh
# chmod +x nordvpn-wireguard.sh 

# COMMAND EXAMPLES:
# 1. ./nordvpn-wireguard.sh nl       -> NordLynx-nl1234.conf
# 2. ./nordvpn-wireguard.sh nl999    -> NordLynx-nl999.conf

# OPTION: REMOVE NORDVPN
# IS NO LONGER NECESSARY:
# nordvpn disconnect
# sudo apt purge nordvpn -y
# sudo apt autoremove -y
# sudo rm -rf /var/lib/nordvpn /var/run/nordvpn.sock

# EXTRA:
# Edit the generated .conf file with a text editor.
# Optional: set your own DNS servers.
# The .conf file can be used to generate a WireGuard QR:
# https://wobbo.org/qr/#wireguard

# 1. CHECK INPUT
if [ -z "$1" ]; then
    echo "Usage:   $0 <country_code_or_server_id>"
    echo "Example: $0 nl  OR  $0 nl999"
    exit 1
fi

SERVER_ARG=$1

echo 
echo " 1. Cleaning up old connections"
nordvpn disconnect > /dev/null 2>&1

# HARD RESET: Force the kernel to forget old keys
if ip link show nordlynx > /dev/null 2>&1; then
    sudo ip link delete nordlynx
fi

echo " 2. Preparing Connection to $SERVER_ARG"

# Force Key Refresh
nordvpn set technology openvpn > /dev/null 2>&1
sleep 1
nordvpn set technology nordlynx > /dev/null 2>&1

# Connect
echo 
echo " Connecting: to $SERVER_ARG..."
echo 
nordvpn connect "$SERVER_ARG"

# Wait loop for valid connection
MAX_RETRIES=20
COUNT=0
echo 
echo " Waiting for valid handshake..."
while [ $COUNT -lt $MAX_RETRIES ]; do
    if sudo wg show nordlynx private-key > /dev/null 2>&1; then
        CHECK_KEY=$(sudo wg show nordlynx private-key)
        if [ -n "$CHECK_KEY" ]; then
            break
        fi
    fi
    sleep 1
    ((COUNT++))
done

if [ $COUNT -eq $MAX_RETRIES ]; then
    echo " ERROR: Timeout. Connection failed."
    exit 1
fi

sleep 3
echo 
echo " 3. Extracting Credentials"

# Get Hostname and remove hidden characters (\r)
RAW_HOSTNAME=$(nordvpn status | grep -i "Hostname" | awk '{print $2}')
SERVER_CODE=$(echo "$RAW_HOSTNAME" | cut -d'.' -f1 | tr -d '\r' | tr -d '\n')

# Final Filename
OUTPUT_FILE="NordLynx-${SERVER_CODE}.conf"

echo "    Target Server: $SERVER_CODE"

# Extract Secrets
PRIVATE_KEY=$(sudo wg show nordlynx private-key)
PUBLIC_KEY=$(sudo wg show nordlynx | grep "peer:" | awk '{print $2}')
ENDPOINT=$(sudo wg show nordlynx | grep "endpoint:" | awk '{print $2}')
ADDRESS=$(ip -4 addr show nordlynx | grep inet | awk '{print $2}' | cut -d'/' -f1)
CREATED_AT=$(date "+%Y-%m-%d %H:%M:%S (%Z)")

# Write the .conf file
cat <<EOF > "$OUTPUT_FILE"
# NordVPN Server: $SERVER_CODE
# Created: $CREATED_AT
# Generated:
# https://wobbo.org/install/2026-01-21/nordvpn-wireguard.sh
# https://forums.raspberrypi.com/viewtopic.php?t=395466

[Interface]
PrivateKey = $PRIVATE_KEY
Address = $ADDRESS/32
# option: DNS = 103.86.96.100, 103.86.99.100

[Peer]
PublicKey = $PUBLIC_KEY
AllowedIPs = 0.0.0.0/0
Endpoint = $ENDPOINT
PersistentKeepalive = 25
EOF

echo "    Success! Saved as: $OUTPUT_FILE"

echo " 4. Cleanup"
nordvpn disconnect > /dev/null 2>&1
echo 
echo " Disconnected."
echo 
