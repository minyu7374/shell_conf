# 一次性处理 主要是环境变量

#-- PATH追加
# go
#export GOPROXY=https://goproxy.cn,https://goproxy.io,direct
GOPATH="$HOME/.go"
PATH="$GOPATH/bin:$PATH"

# nodejs bun
BUN_INSTALL="$HOME/.bun"
PATH="$BUN_INSTALL/bin:$PATH"

# rust
PATH="$HOME/.cargo/bin:$PATH"
# 个人脚本安装方式
# [ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
# 清理cache
# cargo cache --autoclean

# haskell
# 优先使用emerge安装，https://wiki.gentoo.org/wiki/Haskell
PATH="$HOME/.cabal/bin:$PATH"
# 个人脚本安装方式
# [ -f "$HOME/.ghcup/env" ] && source "$HOME/.ghcup/env"

# python
# 用户级python环境
# python -m venv (--system-site-packages) ~/.venv
PATH="$HOME/.venv/bin:$PATH"

# 项目级python环境
# curl https://pyenv.run | bash
PYENV_ROOT="$HOME/.pyenv"
PATH="$PYENV_ROOT/bin:$PATH"
# pyenv PATH 处理太低效，结合direnv在项目路径下再执行
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"

# .local 等个人配置
PATH="$HOME/.config/emacs/bin:$PATH"
PATH="$HOME/.local/bin:$PATH"

export GOPATH BUN_INSTALL PYENV_ROOT
export PATH

#-- 系统基础信息
_OS=$(uname -s)
_HOST_NAME="$(hostname -s 2>/dev/null || uname -n)"

export _OS _HOST_NAME

# Linux 拆分发行版信息
if [[ "$_OS" = "Linux" ]]; then
    # _OS_NAME="$(grep '^NAME=' /etc/os-release | cut -d= -f2 | xargs)" # 子进程调用太多
    # . /etc/os-release # 利用source, 减少子进程调用, 但是额外变量太多
    IFS='=' read -r _ _OS_NAME </etc/os-release
    # _OS_NAME=${_OS_NAME#\"}; _OS_NAME=${_OS_NAME%\"}
    export _OS_NAME
fi

# #-- .profile.d 扩展其他配置
# for sh in "$HOME"/.profile.d/*.sh; do
    # # 只source开启执行权限的，方便开关功能控制 [ -x "$sh" ]
    # . "$sh"
# done
# unset sh
