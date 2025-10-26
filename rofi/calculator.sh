#!/bin/bash

rofi -show calc -modi calc -no-show-match -no-sort -terse -no-persist-history -replace -config ".config/rofi/calculator.rasi" -calc-command "echo {result} | wl-copy"
