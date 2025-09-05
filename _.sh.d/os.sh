#!/bin/bash

#-- 常用命令alias
alias rm='rm -I'
alias del='rm -i'

# alias ls='ls --color=auto'
which eza >/dev/null 2>&1 && {
    alias ls=eza
    alias lt='eza -T'
    alias llt='eza -lhT'
    alias lat='eza -lAhT'
}

if [[ "$_OS" = Darwin ]]; then
    alias date='gdate'
    alias trust-app="sudo xattr -d com.apple.quarantine"
else
    alias open='xdg-open'
fi

#-- 剪贴板
if [[ -n "$ZSH_VERSION" ]]; then
    # zsh 中 omzl::clipboard 有详细的分情况alias，直接使用
    alias cby=clipcopy
    alias cbp=clippaste
elif [[ "$_OS" = Darwin ]]; then
    alias cby='pbcopy'
    alias cbp='pbpaste'
elif [ -n "$WAYLAND_DISPLAY" ]; then
    alias cby='wl-copy'
    alias cbp='wl-paste'
else
    alias cby='xsel -ib'
    alias cbp='xsel -ob'
fi

[[ "$_OS" = Linux ]] && { #---only for Linux
#-- 监控
alias watch-sensors='watch sensors'
alias watch-cpu='watch grep MHz /proc/cpuinfo'

#-- 软件包管理
[[ "$_OS_NAME" =~ Gentoo ]] && {
    # systemd-cron 每次修改crontab会有异常执行，用回cronie
    # alias crontab='sudo crontab-systemd -u $USER'
    alias crontab='sudo /usr/bin/crontab -u $USER'

    alias kernel-update="sudo genkernel all --menuconfig --microcode=amd && emerge --quiet @module-rebuild"
    alias system-update="sudo emerge --quiet --update --newuse --deep --keep-going --ask @world"
    alias system-clean='sudo emerge --depclean'
    # alias system-clean-safe='sudo emerge --depclean --with-bdeps=y'
    # alias system-clean-unsafe='sudo emerge --depclean --with-bdeps=n'
    # alias system-clean-dryrun='sudo emerge --depclean --with-bdeps=n --ask --pretend'
    equery-list() {
        [ $# -eq 0 ] && set -- '@world'
        equery l -o -F '$cp -$fullversion ::$repo :$slot' "$@"
    }
}

[[ "$_OS_NAME" =~ Arch ]] && {
    alias pacman-clean='sudo pacman -Rns $(pacman -Qdtq)'
}

#-- 虚拟化
# kms(windows官方激活服务)
kms-run() { timeout "${1:-300}" vlmcsd; }
alias kms-rund='vlmcsd'
alias kms-stop='pkill -9 vlmcsd'
# alias kms-run='sudo systemctl start docker; docker stop kms; docker rm kms; docker run --name kms -it -p 1688:1688 kms_server /bin/bash'
# alias kms-rund='sudo systemctl start docker; docker stop kms; docker rm kms; docker run -d --name kms -p 1688:1688 kms_server'
# alias kms-stop='docker stop kms; docker rm kms'

alias win11-conv='cd ~/VirtualMachine && qemu-img convert -f vmdk -O raw win11.vmdk win11.raw'
alias vmware-kill='/usr/local/bin/vm-kill vmware'
alias vbox-kill='/usr/local/bin/vm-kill vbox'
alias kvm-kill='/usr/local/bin/vm-kill kvm'

#-- systemd
_systemd-action() {
    local action="${1:-start}"
    case "$action" in
    on)
        action=start
        ;;
    off)
        action=stop
        ;;
    ON)
        action=restart
        ;;
    ss)
        action=status
        ;;
    esac
    echo "$action"
}

systemctl-user() {
    [ $# -lt 2 ] && {
        echo -e "Usage:\n\t$0 <action> [options...] <prog>"
        return 1
    }
    local action
    action=$(_systemd-action "$1")
    shift
    systemctl "$action" --user "$@"
}

systemctl-sudo() {
    [ $# -lt 2 ] && {
        echo -e "Usage:\n\t$0 <action> [options...] <prog>"
        return 1
    }
    local action
    action=$(_systemd-action "$1")
    shift
    sudo systemctl "$action" "$@"
}

#-- 虚拟摄像机(处理部分软件不支持wayland下录幕问题)
vcarm-open() {
    sudo modprobe --remove v4l2loopback
    sudo modprobe v4l2loopback devices=2
}
} #---end Linux
