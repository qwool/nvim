#!/usr/bin/env bash
set +e

maybe() {
	pgrep $1 > /dev/null 2>&1 || ($1 "${@:2}" &)
}

redo() {
	killall $1 2>/dev/null; $1 "${@:2}" &
}

if_has() { command -v $1 > /dev/null && $1; }

maybe mako
redo waybar
redo swaybg -i ~/Pictures/Wallpapers/4965cf54cd2f9a5d113337576e1cca88.jpg
maybe keyd-application-mapper
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wlroots
echo "Xft.dpi: 140" | xrdb -merge
pgrep xfce-polkit || /usr/lib/xfce-polkit/xfce-polkit
redo swayidle \
	timeout 120 'light > ~/.config/mango/last_light; light -S 30' \
	resume 'light -S $(cat ~/.config/mango/last_light)'
	# timeout 1800 'mmsg -d disable_monitor,*' \
	# resume 'mmsg -d enable_monitor,*' \

maybe sway-audio-idle-inhibit
