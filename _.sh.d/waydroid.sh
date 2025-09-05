#!/bin/bash

[[ "$_OS" = Linux ]] || return # only for Linux

alias waydroid-xdg='export XDG_SESSION_TYPE=wayland'
alias waydroid-launch='waydroid show-full-ui'
alias waydroid-show='waydroid show-full-ui'

waydroid-run() {
    #set -x
    local action="${1:-start}"
    sudo systemctl "$action" waydroid-container.service

    sleep 0.5
    # x11 上通过weston运行时，需要设置环境变量
    env XDG_SESSION_TYPE=wayland nohup waydroid session "$action" >/dev/null &
    disown

    sleep 0.5
    # local target_zone=internal
    local target_zone=trusted
    local zone
    zone="$(nmcli connection show waydroid0 | grep zone | tail -n 1 | awk '{print $2}')"
    if [ "$zone" != "$target_zone" ]; then
        nmcli connection modify waydroid0 connection.zone "$target_zone"
        # which firewall-cmd && sudo firewall-cmd --zone="$target_zone" --add-interface=waydroid0
    fi
}

waydroid-resize() {
    local width height
    case "$1" in
    full)
        width=1920
        height=1080
        ;;
    normal)
        width=576
        height=1024
        ;;
    pad)
        width=1536
        height=864
        ;;
    phone)
        width=576
        height=864
        ;;
    *)
        width="${1:-576}"
        height="${2:-1024}"
        ;;
    esac

    echo "resize to $width x $height"
    waydroid prop set persist.waydroid.width "$width"
    waydroid prop set persist.waydroid.height "$height"

    sudo systemctl restart waydroid-container.service
}

# 分别在arch和gentoo上安装的waydroid mac地址一致，暂时不需要人工修改
# waydroid-mac() {
# sudo waydroid shell <<EOF
# ip link set dev eth0@if14 down
# ip link set dev eth0@if14 address 00:16:3e:f9:d3:03
# ip link set dev eth0@if14 up
# EOF
# }
