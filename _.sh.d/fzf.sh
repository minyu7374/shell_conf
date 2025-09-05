fdf() {
    local params=()
    [[ "$1" == "d" || "$1" == "f" ]] && {
        params+=("--type" "$1")
        shift
    }
    [[ "$1" == "i" ]] && {
        params+=("--hidden")
        shift
    }
    [[ $# -gt 0 ]] && params+=("$@")

    # 预览逻辑：目录 -> eza, 文件 -> bat
    # local preview_cmd='[[ -d {} ]] && eza -la --color=always {} || bat --style=numbers --color=always --line-range=:200 {}'
    local preview_cmd='[[ -d {} ]] && eza -la --color=always {} || fzf-preview.sh {}:200'
    fd "${params[@]}" | fzf --ansi --height=75% --preview-window=right:60%:wrap --preview "$preview_cmd"
}

fdf-do() {
    local cmd="${1:-echo}"
    shift
    fdf "$cmd" "$@"
}

# 常用 alias
alias fdc='fdf-do cd d'
alias fdo='fdf-do open f'
alias fdv='fdf-do cat f'

alias fdci='fdf-do cd d i'
alias fdoi='fdf-do open f i'
alias fdvi='fdf-do cat f i'

alias-fzf() {
    alias | sed 's/^alias //' | fzf --ansi --preview "echo {}" \
        --height=60% --preview-window=right:65%:wrap --layout=reverse | awk -F= '{print $1}'
}

alias alsf=alias-fzf
alias alsf!='eval "$(alias-fzf)"'

[ -n "$ZSH_VERSION" ] && {
    # 指向fd的补全
    compdef _fd fdf

    # # fdf-widget 默认行为已同步到fzf_file_widget，不需要单独创建widget了
    # fdf-widget() {
    # local selected
    # selected=$(fdf) && [[ -n $selected ]] && LBUFFER+="$selected "
    # zle redisplay
    # }
    # zle -N fdf-widget
    # bindkey '\et' fdf-widget

    # 替代 OMZP::aliases
    alias-fzf-widget() {
        local selected
        selected=$(alias-fzf) && [[ -n $selected ]] && LBUFFER+="$selected "
        zle redisplay
    }
    zle -N alias-fzf-widget
    bindkey '\ea' alias-fzf-widget
}
