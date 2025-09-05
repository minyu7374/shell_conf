#!/bin/bash

proxy-on() {
    local host="127.0.0.1"
    local user_pass=""
    local socks_port http_port

    case "$1" in
    clash)
        # mixed 7890
        socks_port=7891
        http_port=7892
        # user_pass="$(pass clash/user_pass)" #<USER>:<PWD>
        ;;
    mihomo)
        # mixed 7897
        socks_port=7898
        http_port=7899
        ;;
    v2ray)
        socks_port=10808
        http_port=10809
        ;;
    # 借助 privoxy 提供http服务
    trojan)
        socks_port=8008
        http_port=8118
        ;;
    # ssh 转发vps本地v2ray服务
    forward)
        socks_port=20808
        http_port=20809
        ;;
    # 虚拟机/容器代理转发 every proxy / tiny-proxy
    waydroid)
        host="192.168.240.112"
        socks_port=1080
        http_port=8080
        ;;
    vbridge)
        host="192.168.0.110"
        socks_port=
        http_port=8888
        ;;
    vnat)
        host="192.168.122.139"
        socks_port=
        http_port=8888
        ;;
    esac

    if [ -n "$user_pass" ]; then
        host="$user_pass@$host"
    fi

    [ -n "$socks_port" ] && {
        #local socks_server="socks5://$host:$socks_port"
        local socks_server="socks5h://$host:$socks_port"

        export http_proxy=$socks_server
        export https_proxy=$socks_server
        export socks_proxy=$socks_server

        export HTTP_PROXY=$socks_server
        export HTTPS_PROXY=$socks_server
        export SOCKS_PROXY=$socks_server

        export ALL_PROXY=$socks_server
    }

    [ -n "$http_port" ] && {
        local http_server="http://$host:$http_port"

        export http_proxy=$http_server
        export https_proxy=$http_server
        export ftp_proxy=$http_server

        export HTTP_PROXY=$http_server
        export HTTPS_PROXY=$http_server
        export FTP_PROXY=$http_server

        #export ALL_PROXY=$http_server
    }

    export NO_PROXY="localhost,127.0.0.0/8,10.0.0.0/8,192.168.0.0/16"
}

proxy-off() {
    unset http_proxy https_proxy ftp_proxy socks_proxy
    unset HTTP_PROXY HTTPS_PROXY FTP_PROXY SOCKS_PROXY
    unset ALL_PROXY NO_PROXY
}
proxy-do() {
    proxy-on "$1"
    shift
    "$@"
    proxy-off
}

proxy-forward-open() {
    # home / vps-x|x86|x64 / vps-z|z86|z64
    local vps="${1:-home}"
    nohup ssh "${vps}" -nNT -L 20808:127.0.0.1:10808 >/dev/null &
    disown
    nohup ssh "${vps}" -nNT -L 20809:127.0.0.1:10809 >/dev/null &
    disown
}
proxy-forward-close() {
    ps -eo pid,command | grep -E "ssh .* -nNT -L 2080[89]:127.0.0.1:1080[89]" | awk '{print $1}' | xargs -I{} kill -9 {}
}

alias proxy-clash-on='proxy-on clash'
alias proxy-mihomo-on='proxy-on mihomo'
alias proxy-v2ray-on='proxy-on v2ray'
alias proxy-trojan-on='proxy-on trojan'
alias proxy-forward-on='proxy-on forward'
alias proxy-waydroid-on='proxy-on waydroid'
alias proxy-vbridge-on='proxy-on vbridge'
alias proxy-vnat-on='proxy-on vnat'

alias proxy-clash-do='proxy-do clash'
alias proxy-mihomo-do='proxy-do mihomo'
alias proxy-v2ray-do='proxy-do v2ray'
alias proxy-trojan-do='proxy-do trojan'
alias proxy-forward-do='proxy-do forward'
alias proxy-waydroid-do='proxy-do waydroid'
alias proxy-vbridge-do='proxy-do vbridge'
alias proxy-vnat-do='proxy-do vnat'

alias proxy-forward-home='proxy-forward-open home'
alias proxy-forward-vps-x-paris='proxy-forward-open vps-x-paris'
alias proxy-forward-vps-e-paris='proxy-forward-open vps-e-paris'
alias proxy-forward-vps-m-paris='proxy-forward-open vps-m-paris'

alias proxy-forward-vps-z-paris='proxy-forward-open vps-z-paris'
alias proxy-forward-vps-z-sing='proxy-forward-open vps-z-sing'
alias proxy-forward-vps-e-skn='proxy-forward-open vps-e-skn'
alias proxy-forward-vps-m-skn='proxy-forward-open vps-m-skn'

[[ "$_HOST_NAME" =~ GMK ]] && proxy-on clash
