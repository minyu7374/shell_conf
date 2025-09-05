# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]; then
    # Shell is non-interactive.  Be done now!
    return
fi

# Put your fun stuff here.
# source /usr/share/bash-completion/completions/fzf
# source /usr/share/fzf/key-bindings.bash
FZF_CTRL_T_COMMAND="" FZF_ALT_C_COMMAND="" eval "$(fzf --bash)"
eval "$(mcfly init bash)"
source "$HOME/.mcfly.rc"

eval "$(lua ~/.local/z.lua/z.lua --init bash enhanced once fzf)"
[[ "$_OS" = Drawin ]] && source /opt/homebrew/etc/profile.d/bash_completion.sh

eval "$(direnv hook bash)"

for sh in "$HOME"/.sh.d/*.sh; do
    #[ -x "$sh" ] &&
    . "$sh"
done
unset sh
