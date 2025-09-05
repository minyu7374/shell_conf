#!/bin/bash

## git
git-repo-clean() {
    git filter-repo --refs "${1:-"$(git symbolic-ref --short HEAD)"}" --force &&
        alias git-gc-clean="git gc --prune=now --aggressive"
}

alias gst='git status'
alias gds='forgit::diff --staged'
alias gaa='git add --all'
alias gap='git apply'
alias grm='git rm'
alias grmc='git rm --cached'
alias gc='git commit --verbose'
alias gc!='git commit --verbose --amend'

alias gf='git fetch'
alias gl='git pull'
alias gp='git push'
alias gpf!='git push --force'

alias glos='git log --stat'
alias glog='git log --graph'

## python
alias venv-in='source $HOME/.venv/bin/activate'
alias venv-out="deactivate"

alias pyenv-in='pyenv activate'
alias pyenv-out="pyenv deactivate"

pyenv-local() {
    pyenv virtualenv "${2:-3.7}" "$1"
    pyenv local "$1"

    # git clone https://github.com/alefpereira/pyenv-pyright.git $(pyenv root)/plugins/pyenv-pyright
    pyenv pyright
}

## compile_commands for clangd/ccls
gen-compile-cmds() {
    local type="$1"

    if [ -z "$type" ]; then
        if [ -f "CMakeLists.txt" ]; then
            type="cmake"
        elif [[ -f configure || -f MakeFile ]]; then
            type="make"
        fi
    fi

    case $type in
    cmake)
        cmake -H. -BDebug -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=YES
        ln -s Debug/compile_commands.json .
        ;;
    make)
        [ -f ./configure ] && ./configure
        make clean
        bear -- make
        ;;
    *)
        echo "only support cmake/make"
        ;;
    esac
}
