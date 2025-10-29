#!/usr/bin/env bash

# Options with actual icon paths

data=$( cat ~/.config/rofi/quickmenuData.txt )

DELIMITER="|"

IFS="$DELIMITER" read -r rofi_data num_menu_entries icon_size icon_padding <<< "$data"

THEME_STR="window {width: $(($icon_padding * 2 * $num_menu_entries + $icon_size * $num_menu_entries));} listview { columns: $num_menu_entries; } element-icon { padding: $icon_padding px; size: $icon_size px;}"

selection=$(echo -en $rofi_data | rofi -dmenu -show drun -p "" -show-icons -config ~/.config/rofi/quickmenu.rasi -location 6 -theme-str "$THEME_STR" -replace)

case "$selection" in
"Firefox") firefox & ;;
"Foot Terminal") foot & ;;
esac
