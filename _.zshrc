[[ $- != *i* ]] && return

# 性能报告
#zmodload zsh/zprof
# 注：将 .zshrc 编译成 Zsh 字节码，加快解析速度
# zcompile ~/.zshrc

# 结合zinit异步加载延迟处理
# autoload -Uz compinit
# compinit -C
# # zstyle ':completion::complete:*' use-cache 1

# p10k优化处理
# autoload -Uz promptinit
# promptinit
# [[ "$_OS_NAME" =~ Gentoo ]] && prompt gentoo

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ### Added by Zinit's installer
# if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    # print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    # command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    # command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        # print -P "%F{33} %F{34}Installation successful.%f%b" || \
        # print -P "%F{160} The clone has failed.%f%b"
# fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit

## 加载 Zinit 核心 Annex
# zinit light-mode for \
    # zdharma-continuum/zinit-annex-as-monitor \
    # zdharma-continuum/zinit-annex-bin-gem-node \
    # zdharma-continuum/zinit-annex-patch-dl \
    # zdharma-continuum/zinit-annex-rust

## p10k主题
zinit ice depth=1
zinit light romkatv/powerlevel10k

## 加载 OMZ 框架及部分插件
# zinit snippet OMZ::lib/key-bindings.zsh
zinit for \
    OMZL::key-bindings.zsh \
    OMZL::history.zsh
zinit wait lucid for \
    OMZL::completion.zsh \
    OMZL::directories.zsh \
    OMZL::clipboard.zsh \
    OMZP::sudo \
    OMZP::git

## zsh-vi-mode(initmode binkey冲突解决) 替换 OMZP::vi-mode
zinit light-mode wait lucid for \
 depth=1 atinit"ZVM_INIT_MODE=sourcing" \
    jeffreytse/zsh-vi-mode

## 语法高亮和匹配补全

# 对compinit做优化处理，定期整体重新初始化，不使用zicompinit了
_compinit_opt() {
    autoload -Uz compinit
    # local zcomp_path=${ZINIT[ZCOMPDUMP_PATH]:-${ZDOTDIR:-$HOME}/.zcompdump}
    local zcomp_path="$HOME/.zcompdump"
    local _zcomp_files; _zcomp_files=($zcomp_path(Nm-15)) # 找到指定天内修改的文件
    (( $#_zcomp_files )) && compinit -C || compinit
    [[ ! -f $zcomp_path.zwc || $zcomp_path -nt $zcomp_path.zwc ]] && zcompile $zcomp_path
}

# zsh内置历史命令匹配仅支持前缀，history-substring-search 支持子串匹配，但没有mcfly全面，仅作为最近命令快速查询使用
zinit light-mode wait lucid for \
 atinit"_compinit_opt; zicdreplay" \
    zdharma-continuum/fast-syntax-highlighting \
 blockf \
    zsh-users/zsh-completions \
 atload"!_zsh_autosuggest_start; bindkey ^_ autosuggest-accept" \
    zsh-users/zsh-autosuggestions \
 atload'
     bindkey '^P' history-substring-search-up
     bindkey '^N' history-substring-search-down
     export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
 ' \
    zsh-users/zsh-history-substring-search

## fzf + mcfly 模糊搜索(历史命令、文件)

# history-search-multi-word、fzf的历史搜索都不如mcfly全面
# zinit ice lucid wait"0b" from"gh-r" as"program" atload'source <(mcfly init zsh)'
# zinit light cantino/mcfly

# 理论上应该保证先加载完fzf，再加载mcfly和fzf-tab，保证ctrl+r,alt+i的归属，但是目前看这样写没有问题

# fzf配置相对较多，单独创建一个函数
_fzf_conf() {
    local _fzf_zle_comm_opts="--ansi --height=75% --preview-window=right:60%:wrap"
    #_ctrl_t_preview="[[ -d {} ]] && eza -la --color=always || bat --style=numbers --color=always --line-range=:200 {}"
    local _ctrl_t_preview="[[ -d {} ]] && eza -la --color=always || fzf-preview.sh {}:200"
    local _alt_c_preview="eza -la --color=always {}"

    FZF_DEFAULT_COMMAND="fd --strip-cwd-prefix --follow --exclude .git"

    FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --type d"

    FZF_CTRL_T_OPTS="$_fzf_zle_comm_opts --bind 'alt-h:reload($FZF_CTRL_T_COMMAND --hidden),alt-H:reload($FZF_CTRL_T_COMMAND)' --preview \"$_ctrl_t_preview\""
    FZF_ALT_C_OPTS="$_fzf_zle_comm_opts --bind 'alt-h:reload($FZF_ALT_C_COMMAND --hidden),alt-H:reload($FZF_ALT_C_COMMAND)' --preview \"$_alt_c_preview\""

    bindkey "^[f" fzf-file-widget #和fzf-cd-widget以及自己定义的alias-fzf-widget保持相似的快捷键
}

zinit light-mode wait lucid for \
 as"null" atload'
    source <(fzf --zsh); _fzf_conf
    source <(mcfly init zsh); source "$HOME/.mcfly.rc"
    source <(lua ~/.local/z.lua/z.lua --init zsh enhanced once fzf)
' \
    zdharma-continuum/null \
    Aloxaf/fzf-tab \
    wfxr/forgit

## direnv
# zinit ice lucid wait as"program" make atclone"direnv hook zsh > zhook.zsh" atpull"%atclone" src"zhook.zsh"
# zinit light direnv/direnv
zinit ice lucid wait as"null" atload'source <(direnv hook zsh)'
zinit light zdharma-continuum/null

## 其他个人配置扩展
zinit ice lucid wait as"null" atload'for sh in "$HOME"/.sh.d/*.sh; do source "$sh"; done'
zinit light zdharma-continuum/null

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zprof
