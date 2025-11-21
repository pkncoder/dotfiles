#!/usr/bin/env bash
# Reads an INI file from Noctalia-shell and broadcasts updated colors to all
# running foot terminals using OSC color sequences.

set -euo pipefail

COLFILE="$1"

if [ ! -f "$COLFILE" ]; then
    echo "Color file not found: $COLFILE" >&2
    exit 1
fi

# Function: convert hex (rrggbb) → rr/gg/bb
hex_to_rgb_comp() {
    local hex="$1"
    hex="${hex#\#}"
    hex="${hex,,}" # lowercase
    echo "${hex:0:2}/${hex:2:2}/${hex:4:2}"
}

# Read INI: extract only "key=value" pairs after [colors]
declare -A C
in_colors_section=0

while IFS= read -r line; do
    case "$line" in
    "[colors]")
        in_colors_section=1
        ;;
    \[*\])
        in_colors_section=0
        ;;
    *=*)
        if [ "$in_colors_section" -eq 1 ]; then
            key="${line%%=*}"
            val="${line#*=}"
            val="${val//[[:space:]]/}" # remove spaces
            C["$key"]="$val"
        fi
        ;;
    esac
done <"$COLFILE"

# OSC building helpers
ESC=$'\033'
BEL=$'\a'
osc=""

# Foot uses standard palette indexes 0–7 (regular), 8–15 (bright)
# Map your keys to palette slots
map_palette() {
    local index="$1"
    local key="$2"
    if [[ -n "${C[$key]:-}" ]]; then
        local rgb
        rgb=$(hex_to_rgb_comp "${C[$key]}")
        osc+="${ESC}]4;${index};rgb:${rgb}${BEL}"
    fi
}

# regular 0–7
map_palette 0 regular0
map_palette 1 regular1
map_palette 2 regular2
map_palette 3 regular3
map_palette 4 regular4
map_palette 5 regular5
map_palette 6 regular6
map_palette 7 regular7

# bright 8–15
map_palette 8 bright0
map_palette 9 bright1
map_palette 10 bright2
map_palette 11 bright3
map_palette 12 bright4
map_palette 13 bright5
map_palette 14 bright6
map_palette 15 bright7

# Foreground / background
if [[ -n "${C[foreground]:-}" ]]; then
    osc+="${ESC}]10;rgb:$(hex_to_rgb_comp "${C[foreground]}")${BEL}"
fi
if [[ -n "${C[background]:-}" ]]; then
    osc+="${ESC}]11;rgb:$(hex_to_rgb_comp "${C[background]}")${BEL}"
fi

# Cursor color
# Noctalia gives `cursor=4b4358 e8dfee` → background + foreground
if [[ -n "${C[cursor]:-}" ]]; then
    cursor_bg="${C[cursor]% *}"
    cursor_fg="${C[cursor]#* }"

    # cursor background
    osc+="${ESC}]12;rgb:$(hex_to_rgb_comp "$cursor_bg")${BEL}"

    # cursor text color (OSC 13)
    osc+="${ESC}]13;rgb:$(hex_to_rgb_comp "$cursor_fg")${BEL}"
fi

# Selection colors
if [[ -n "${C[selection - foreground]:-}" ]]; then
    osc+="${ESC}]17;rgb:$(hex_to_rgb_comp "${C[selection - foreground]}")${BEL}"
fi
if [[ -n "${C[selection - background]:-}" ]]; then
    osc+="${ESC}]19;rgb:$(hex_to_rgb_comp "${C[selection - background]}")${BEL}"
fi

# Send to all pts devices owned by the user
USERID=$(id -u)

for tty in /dev/pts/*; do
    [[ -c "$tty" ]] || continue

    # Only write to ttys owned by this user
    if [[ "$(stat -c '%u' "$tty")" -eq "$USERID" ]]; then
        printf "%b" "$osc" >"$tty" 2>/dev/null || true
    fi
done

echo "Updated foot terminal colors."
