function nt
    set notes_dir ~/notes
    if test (count $argv) -gt 0
        set file "$notes_dir/$argv.md"
        test -f $file || touch $file
        $EDITOR $file
    else
        set selected_file (ls -1 $notes_dir |\
            fzf --preview 'bat --style=numbers --color=always --line-range=:500 --paging=never '$notes_dir'/{}'\
            --height=60% --border --prompt="notes! " --preview-window=right:50%:wrap\
        )
        if test -n "$selected_file"
            $EDITOR "$notes_dir/$selected_file"
        end
    end
end

