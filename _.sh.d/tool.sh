#!/bin/bash

### tmux
#which tmux >/dev/null 2>&1 && {
#    alias tmux='tmux -2'
#    alias tmux-init='source $HOME/.profile.d/tmux.sh'
#    alias tmux-main='tmux at -t main'
#    alias tmux-tool='tmux at -t tool'
#    alias tmux-kill='tmux kill-server'
#    alias tmux-ls='tmux ls'
#    [[ "$TERM_PROGRAM" = tmux ]] && alias ssh='tssh'
#}
#
### screen
#which screen >/dev/null 2>&1 && {
#    alias screen-main="screen -R -S main"
#    alias screen-main-x="screen -x -S main"
#    alias screen-main-kill="screen -S main -X quit"
#    alias screen-ls="screen -ls"
#    screen-kill() {
#        [ "$1" = all ] && {
#            screen -ls | grep -oP '\d+\.\S+' | xargs -I{} screen -S {} -X quit
#        }
#        screen -S "${1:-main}" -X quit
#    }
#}

# ssh
ssh-switch() {
    case "$1" in
    t | tssh)
        alias ssh=tssh
        ;;
    k | kssh | kitty)
        alias ssh='kitty +kitten ssh'
        ;;
    u | off)
        alias ssh && unalias ssh
        ;;
    esac
    which ssh
}

ssh-vps-list() {
    grep 'host vps' ~/.ssh/config.d/vps | cut -d' ' -f 2
}

# localip
alias localip='curl myip.ipip.net'
alias localip-dig='dig +short myip.opendns.com @resolver1.opendns.com'

# translator
alias tran='/usr/local/bin/trans -x 127.0.0.1:7897'
# alias trans='HTTPS_PROXY="http://127.0.0.1:7890" $HOME/.venv/bin/trans' # --no-notification'
# alias tranf='HTTPS_PROXY="http://127.0.0.1:7890" $HOME/.venv/bin/trans --translators=google,bing,haici,stardict' # --no-notification'
# alias tranb='$HOME/.venv/bin/trans --translators=bing,haici' # --no-notification'
# alias trana='$HOME/.venv/bin/trans --translators=stardict' # --no-notification'

if [[ "$_OS" == Darwin ]]; then
    alias clock='tty-clock -c'
else
    alias clock=peaclock
fi

alias unzip-win='unzip -O CP936'
# alias aria2cc='aria2c --conf=/etc/aria2.conf'

# mpd
mpd-user() {
    systemctl-user "${1:-start}" mpd
}
alias mpc-add-all='mpc listall | mpc add'

# samba
file-share() {
    systemctl-sudo "${1:-start}" smbd
}

# lan-mouse
mouse-share() {
    systemctl-user "${1:-start}" lan-mouse
}

# # barrier => deskflow
# input-share {
# systemctl-user "${1:-start}" deskflow
# }

# dict
alias dictd-forward='nohup ssh home -nNT -L 2628:127.0.0.1:2628 > /dev/null &; disown'

alias dict-online='dict -h dict.org'
dict-less() {
    dict "$@" | less
}

# csv
csv-bom() {
    [[ $# -lt 1 ]] && {
        cat <<EOF
Usage:
    $0 <in_file> [out_file]
    如果in_file不是csv 空格会转换为,分隔符
EOF
        return
    }

    local in_file="$1"
    local out_file="${2:-${in_file%.*}_bom.csv}"
    {
        echo -ne '\xEF\xBB\xBF'
        if [ "${in_file##*.}" = "csv" ]; then
            cat "$in_file"
        else
            tr ' ' ',' <"$in_file"
        fi
    } >"$out_file"
}

# jq
json-schema() {
    jq 'def typeschema:
  if type == "object" then
    with_entries(.value |= typeschema)
  elif type == "array" then
    if length > 0 then [.[0] | typeschema] else [] end
  else
    type
  end;
  typeschema' "$@"
}
