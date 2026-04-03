#!/bin/bash
set -e

echo "==> Removing manually-built binary..."
sudo rm -f /usr/bin/browserpass-linux64

echo "==> Removing manual install lib directory..."
sudo rm -rf /usr/lib/browserpass/

echo "==> Removing leftover docs and licenses..."
sudo rm -rf /usr/share/doc/browserpass/
sudo rm -rf /usr/share/licenses/browserpass/

echo "==> Removing user-level native messaging host symlinks..."
rm -f ~/.mozilla/native-messaging-hosts/com.github.browserpass.native.json
rm -f ~/.config/BraveSoftware/Brave-Browser/NativeMessagingHosts/com.github.browserpass.native.json

echo "==> Removing build artifacts..."
rm -f ~/build/browserpass-native-*.tar.gz
rm -rf ~/build/*browserpass-native-*/

echo "==> Purging old webext-browserpass config files..."
sudo dpkg --purge webext-browserpass 2>/dev/null || true

echo "==> Installing webext-browserpass from apt..."
sudo apt install -y webext-browserpass

echo "==> Done! Browserpass native host is now managed by apt."
echo "    You can delete this script now."
