#!/bin/sh

gnre="$1"
echo "$1" > /home/hdb/.gnre.txt

wallpappGnre=$(cat /home/hdb/.gnre.txt)

#Shuffle WP Folder
wall=$(find ~/Pictures/wallpaper/$wallpappGnre -type f -name "*.jpg" -o -name "*.png" | shuf -n 1)

#Set Wallpaper
hsetroot -center $wall > /dev/null 2>&1

#Set Colors to Wal
wal -q -i $wall

#Cache Wallpaper

cp -f $wall ~/.cache/wal/wal.jpg

#Set Kitty Background Opacity
# kitty @ set-background-opacity 0.6

#Update Rofi colors
cp ~/.cache/wal/colors-rofi-dark.rasi ~/.config/rofi/launchers/type-4/shared/colors.rasi
cp -f ~/.cache/wal/colors-rofi-dark.rasi ~/.config/rofi/powermenu/type-4/shared/colors.rasi

#Update Xresources
cp -f ~/.cache/wal/colors.Xresources ~/.Xresources

#Update Spicetify Theme
# spicetify config color_scheme -qn
# spicetify apply -qn
