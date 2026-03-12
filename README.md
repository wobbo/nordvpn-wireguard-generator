# NordVPN → WireGuard Config Generator

This tool generates a **standalone WireGuard configuration file (.conf)** from a NordVPN connection.

NordVPN uses **NordLynx**, their implementation of the WireGuard protocol. Normally this connection can only be used through the official NordVPN application. This script extracts the required connection parameters and generates a standard WireGuard configuration.

The generated `.conf` file can be imported into any WireGuard client and reused on multiple devices.

Supported use cases include:

* Raspberry Pi systems
* routers
* containers
* GNOME NetworkManager
* Android / iOS WireGuard app
* other Linux systems

![NordVPN WireGuard Example](https://wobbo.org/screenshots/20260117_NordVPN_004_image_mini.webp)

## ⚠️ SECURITY WARNING

The generated `.conf` file works **without a username or password**.

Authentication is handled through a **WireGuard Private Key** stored inside the configuration file.

Treat this file like a **password**.

Anyone who has access to the file can use your **NordVPN subscription**.

Never:

* share the file publicly
* upload it to GitHub
* send it to others
* include it in public backups

Keep the `.conf` file private and secure.

## Why this tool exists

NordVPN does **not provide ready-to-use WireGuard configuration files** for manual setups.

Instead, users are expected to connect through the official NordVPN application.

For many technical setups this is inconvenient or impossible, such as:

* headless Raspberry Pi systems
* routers
* containers
* servers
* custom networking environments

This script extracts the required parameters from an active **NordLynx connection** and generates a fully usable WireGuard configuration file.

## Requirements

Linux system (tested on Raspberry Pi OS).

Required package:

```
sudo apt install wireguard-tools
```

The NordVPN Linux client must also be installed.

## Step 1 — Install NordVPN (temporary)

Install the NordVPN client:

```
sh <(curl -sSf https://downloads.nordcdn.com/apps/linux/install.sh)
```

Add your user to the NordVPN group:

```
sudo usermod -aG nordvpn $USER
```

Reboot the system.

Login afterwards:

```
nordvpn login
```

## Step 2 — Enable NordLynx

Ensure NordVPN is using the WireGuard-based NordLynx protocol:

```
nordvpn set technology nordlynx
```

## Step 3 — Download the script

Download the script:

```
wget https://wobbo.org/install/2026-01-21/nordvpn-wireguard.sh
```

Make it executable:

```
chmod +x nordvpn-wireguard.sh
```

## Step 4 — Generate configuration

Example using a country code:

```
./nordvpn-wireguard.sh nl
```

Example using a specific server:

```
./nordvpn-wireguard.sh nl123
```

The script generates a standalone configuration file:

```
NordVPN-nl123.conf
```

## Step 5 — Import into WireGuard

The generated `.conf` file is fully standalone and can be reused on any device.

### Raspberry Pi / Linux (GNOME)

Settings → Network → VPN → **Import from file**

Select the generated `.conf` file.

### WireGuard CLI

Start connection:

```
sudo wg-quick up NordVPN-nl123.conf
```

Stop connection:

```
sudo wg-quick down NordVPN-nl123.conf
```
![GNOME - WireGuard - QR Code](https://wobbo.org/screenshots/20250119_GNOME_WireGuard_QR.webp)
### Android / iOS

Import the configuration into the official **WireGuard app**. 

### Note for Android / iOS

Opening `.conf` files directly on mobile devices can sometimes fail.

If importing the configuration does not work:

1. Open the `.conf` file in a simple text editor
2. Copy the full contents of the file
3. Go to the WireGuard QR generator:
   https://wobbo.org/qr#type=wireguard
4. Paste the configuration into the generator
5. Scan the generated QR code using the **WireGuard app**

The QR code is generated **locally in your browser** and no configuration data is stored or logged.

## Optional — Remove NordVPN client

Once the configuration file is generated, the NordVPN client is no longer required.

You can remove it to free system resources:

```
nordvpn disconnect
sudo apt purge nordvpn -y
sudo apt autoremove -y
sudo rm -rf /var/lib/nordvpn /var/run/nordvpn.sock
```

Your WireGuard configuration will continue to work without the NordVPN software installed.

## Tested on

* Raspberry Pi OS
* Debian
* GNOME NetworkManager

## License

MIT License
