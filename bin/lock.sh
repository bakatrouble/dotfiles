#!/bin/bash

bg='/tmp/lock.png'
scrot "$bg"
convert "$bg" -filter point -resize 10% -resize 1000% "$bg"
i3lock -u -i "$bg"
rm $bg
