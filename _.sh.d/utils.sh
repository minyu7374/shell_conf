#!/bin/bash

show_progress() {
    local progress=$1
    local total=$2
    local width="${3:-50}"

    local percent=$((100 * progress / total))
    local filled=$((width * progress / total))
    local empty=$((width - filled))

    # echo "$percent $filled $empty"
    local i j
    printf "\r["
    for ((i = 0; i < filled; ++i)); do printf "="; done
    for ((j = 0; j < empty; ++j)); do printf " "; done
    printf "] %d%% | $progress/$total" $percent
    tput el
    if [ "$progress" -eq "$total" ]; then echo -e "\nDone"; fi
}

# Simulate a process
# total_steps=80
# for ((i=1; i<=total_steps; ++i)); do
# show_progress $i $total_steps 80
# sleep 0.1
# done

# 模仿mapfile, bash/zsh可以通用
read_into_array() {
    local __resultvar="$1"

    local -a array
    while read -r line; do
        array+=("$line")
    done

    # 特殊处理 <<<"" 的情况
    if [[ -z "${array[*]}" ]]; then
        array=()
    fi

    eval "$__resultvar=(\"\${array[@]}\")"
}

# join_str "." s1 s2 ...
join_str() {
    local ifs="$1"
    shift
    local str="$1"
    shift

    for val in "$@"; do
        str+="$ifs$val"
    done

    echo "$str"
}

# choose_opt __resultvar prompt opts...
choose_opt() {
    local __resultvar="$1"
    shift
    local PS3="${1:-Choose one opt :> }"
    shift
    select opt in "$@" quit; do
        case "$opt" in
        quit)
            opt=""
            echo "bye"
            break
            ;;
        *)
            if [[ -n "$opt" ]]; then
                # # 兼容 zsh, 移除前后双引号
                # opt="${opt%\"}"
                # opt="${opt#\"}"
                break
            else
                echo 'bad option!'
            fi
            ;;
        esac
    done

    eval "$__resultvar=$opt"
    unset opt
}

urlencode() {
    local LC_ALL=C
    local str="$*"
    for ((i = 0; i < ${#str}; i++)); do
        local c="${str:$i:1}"
        case $c in
        [a-zA-Z0-9.~_-]) printf "%s" "$c" ;;
        # 字符转 ASCII 值技巧： "'$c" 中的单引号 ' 表示将 $c 视为字符字面量，并取其 ASCII 值
        *) printf '%%%02X' "'$c" ;;
        esac
    done
    printf '\n'
}

urlencode-jq() {
    echo -n "$*" | jq -sRr @uri
}

# urlencode-curl() {
# printf -- "%s" "$*" | curl -Gso /dev/null -w "%{url_effective}" --data-urlencode @- "" | cut -c 3-
# }
