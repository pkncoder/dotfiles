#!/usr/bin/env bash

# If an argument is passed, execute the corresponding command
if [[ -n "$1" ]]; then
    case "$1" in
    $'')
        printf "N\n"
        ;;
    $'')
        printf "Y\nN\n"
        ;;
    $'')
        hyprlock
        killall rofi
        ;;
    $'Y')
        reboot
        ;;
    $'N')
        printf "O"
        ;;
    esac
    exit 0
fi

# Print the menu options using ANSI-C quoting
printf $'\n\n\n'
