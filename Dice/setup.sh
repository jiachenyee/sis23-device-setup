# +-----------------+
# | Initial Setup   |
# +-----------------+
mkdir ~/Desktop/.setup
cd ~/Desktop/.setup

# +-----------------+
# | Safe to DC      |
# +-----------------+
osascript -e "set Volume 10"
say SAFE TO DISCONNECT

# +-----------------+
# | Download Assets |
# +-----------------+
curl -Lo CoreAsset.zip https://github.com/jiachenyee/sis23-device-setup/raw/main/Dice/CoreAsset.zip
curl -Lo Dice\ Starter.zip https://github.com/jiachenyee/sis23-device-setup/raw/main/Dice/Dice%20Starter.zip

# +-----------------+
# | Load Dice Asset |
# +-----------------+
unzip -q CoreAsset.zip
rm -rf ~/Library/Application\ Support/com.apple.RealityComposer/CoreAsset/
mv CoreAsset/ ~/Library/Application\ Support/com.apple.RealityComposer/
rm -rf __MACOSX/

echo "Dice asset imported"

# +------------------+
# | Set Up Sessions  |
# +------------------+
unzip -q Dice\ Starter.zip

cp -R Dice\ Starter/ Session\ 1
cp -R Dice\ Starter/ Session\ 2

mv Session\ 1 ~/Desktop/Session\ 1
mv Session\ 2 ~/Desktop/Session\ 2

rm -rf __MACOSX/
rm -rf Dice\ Starter/

echo "Sessions setup"

echo "Setup Complete"

say SETUP COMPLETE