cd ~/Desktop/

mkdir .tmp

cd .tmp

curl -Lo SAMOYED.zip https://github.com/jiachenyee/sis23-device-setup/raw/main/Cow/Starter.zip
unzip SAMOYED.zip
rm -rf __MACOSX
rm SAMOYED.zip

cp -R Starter ../Session\ 1
mv Starter ../Session\ 2

curl -Lo Animals.zip https://github.com/jiachenyee/sis23-device-setup/raw/main/Cow/Animals.zip
unzip Animals.zip
rm -rf __MACOSX
rm Animals.zip

mv Animals ../Animals

cd ..
rm -rf .tmp/
