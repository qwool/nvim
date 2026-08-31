set -gx EDITOR nvim
set -gx HELIX_RUNTIME ~/git/helix/runtime

if not status is-interactive
    exit 0
end

source  $__fish_config_dir/aliases.fish
source  $__fish_config_dir/system.fish

type -q opam && eval (opam env)

type -q cht.sh && complete -c cht.sh -xa '(curl -s cht.sh/:list)'

# __fish_cursor_xterm line

type -q bat && set -x MANPAGER "bat -plman"
type -q nvim && set -x MANPAGER "nvim +Man!"

# utility
if type -q yazi
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
    alias f=y
end

# if test -d "$HOME/.cargo"
# 	source "$HOME/.cargo/env.fish"; end
#
function ln-swap -a from to
    mv $from $to && ln -sf (realpath $to) $from; end

function dot -a what
    ln-swap ~/.config/$what ~/dotfiles/.config/$what; end


# keybinds
bind \cz 'fg 2>/dev/null; commandline -f repaint' # reopen with C-z
bind alt-v fish_clipboard_paste
bind ctrl-h backward-delete-char
bind super-backspace backward-kill-word
bind ctrl-x edit_command_buffer

bind alt-z undo
bind alt-shift-z redo

set -q ZELLIJ_SESSION_NAME &&  bind alt-e "cd (zellij pipe -p filepicker)";

# beam cursor
# echo -ne "\e[5 q"
