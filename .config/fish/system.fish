#!
#! per-system config
#!

fish_add_path -g \
    ~/.local/bin \
    ~/bin \
    ~/bin/ext \
    ~/.cargo/bin \
    ~/.bun/bin \
    ~/.cache/.bun/bin \
    ~/go/bin \
    ~/opt/odin \
    ~/.local/share/zigup \
    ~/.luarocks/bin \
		~/opt/emsdk/ \
		~/opt/emsdk/upstream/emscripten/ \
		/Library/Developer/CommandLineTools/usr/bin/lldb-dap \
		~/.local/bin \


type -q /opt/homebrew/bin/brew && /opt/homebrew/bin/brew shellenv fish | source

# set -l nix_dirs ~/.nix-profile/share/fish/vendor_completions.d \
#     ~/.nix-profile/share/fish/completions \
#     /run/current-system/sw/share/fish/vendor_completions.d
#
# for d in $nix_dirs
#     if test -d $d; and not contains $d $fish_complete_path
#         set -pa fish_complete_path $d; end; end
