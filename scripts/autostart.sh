#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}


#starting utility applications at boot time3lxsession &
#lxsession &
#run pamac-tray &
nm-applet &
numlockx on &
blueman-applet &
flameshot &
picom --config $HOME/.config/picom/picom-blur.conf --experimental-backends -b & 
#picom --config $HOME/.config/picom/picom.conf & 
dunst &
#starting user applications at boot time
sleep 1
run volumeicon &
run cbatticon &
run battray &
#run discord &
#nitrogen --random --set-zoom-fill &
run caffeine -a &
#run vivaldi-stable &
#run firefox &
#run thunar &
#run dropbox &
#run insync start &
#run spotify &
#run atom &
#run telegram-desktop &
# Deas edit
run nitrogen --restore  & # modify feh insted
xscreensaver --no-splash &
#nvidia-settings --load-config-only & # fix multimonitor configuration
#xrandr --output DP-2  --primary &
xset s off -dpms # fix screen dimming during video playback while xscreensaver runs in the backround 
#gsettings set org.gtk.Settings.FileChooser window-size '(800, 600)' #fix the oversized windows
