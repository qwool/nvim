if type -q bat
    abbr lscpu "lscpu | bat -Ppl cpuinfo"
    abbr sensors "sensors | bat -Ppl cpuinfo"
    abbr lsblk "lsblk | bat -Ppl conf"
    abbr lsmod "lsmod | bat -Ppl conf"
end

if type -q zoxide
    zoxide init fish | source
    bind ctrl-g zi repaint
    bind alt-l zi repaint
end

abbr -a tmac "tmux new-session -A -s main"
abbr -a tmcd "tmux set-option -t (tmux display-message -p '#S') default-path (pwd)"
abbr vi nvim
abbr vim nvim
abbr e "\$EDITOR"
abbr rsync-all -a "rsync -av --delete"
if type -q helix
    type -q hx || alias hx helix
end

abbr c cd
abbr cp "cp -r"
abbr rsync -a "rsync -havzP --stats"
abbr cow ="~/projects/cli/cow-tools/main.lua"
alias freload="source ~/.config/fish/config.fish"
if type -q eza
    abbr ls "eza -a"
    abbr l "eza -a"
    abbr ll "eza -l"
else
    abbr ls 'ls --color=auto -A'
    abbr l 'ls --color=auto -A'
    abbr ll 'ls -l --color=auto -A'
end

type -q apt; and abbr apt "sudo apt"
type -q dnf; and abbr dnf "sudo dnf"
type -q xbps-install && abbr xbpi "sudo xbps-install"
if type -q pacman
    abbr p "sudo pacman -"
    abbr pi "sudo pacman --needed -S"
    abbr prns "sudo pacman -Rns"
end

if type -q git
    abbr g git
    abbr ga "git add"
    abbr gaa "git add --all"
    abbr gc "git commit"
    abbr gcd 'git commit -m (date +"%Y-%m-%d %H:%M")'
    abbr gca "git commit -a"
    abbr gd "git diff"
    abbr gl "git pull"
    abbr gp "git push"
    abbr gs "git status"
    abbr glog "git log --oneline --graph"
    abbr gcl "git clone --depth 1"
end

abbr dl-ytm "yt-dlp -x --audio-format mp3"
abbr dl-yt "yt-dlp --format mp4"
alias venv="source .venv/bin/activate.fish"
alias h="eval (horse)"

type -q nixos-rebuild && alias ne="cd /etc/nixos/ && $EDITOR ./configuration.nix"

alias unprint="rg -n -P '[^\x00-\x7F\x{2800}-\x{28FF}]'"
