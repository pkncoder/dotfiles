#!/usr/bin/env bash

# Options with actual icon paths
#
num_menu_entries=2
icon_size=48
icon_padding=6

menu_entries=""
menu_entries+='Firefox\0icon\x1f/usr/share/icons/hicolor/48x48/apps/firefox.png\n'
menu_entries+='Foot Terminal\0icon\x1f/usr/share/icons/hicolor/48x48/apps/foot.png\n'

THEME_STR="window {width: $(($icon_padding * 2 * $num_menu_entries + $icon_size * $num_menu_entries));} listview { columns: $num_menu_entries; } element-icon { padding: $icon_padding px; size: $icon_size px;}"

selection=$(echo -en "$menu_entries" | rofi -dmenu -show drun -p "" -show-icons -config ~/.config/rofi/quickmenu.rasi -theme-str "$THEME_STR" -replace)

case "$selection" in
"Firefox") firefox & ;;
"Foot Terminal") foot & ;;
esac
