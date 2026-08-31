function fish_prompt
	set -l prompt_char '$'
	if test "$TERM" != "dumb"
		for var in LC_ALL LC_CTYPE LANG
			if set -q $var && string match -qi '*.utf-8' $$var
				set prompt_char λ
				break
			end
		end
	end

	set -l last_status $status
	set -l stat
	# if test $last_status -ne 0
	#     echo -ne (set_color red)$last_status"|"(set_color normal)
	# end

	set _prompt_pwd (string replace -- ~ \~ $PWD)
	if test (string length -- $_prompt_pwd) -gt 40
		echo -ne (set_color yellow)(prompt_pwd)
	else
		echo -ne (set_color yellow)$_prompt_pwd
	end
	echo -ne (set_color cyan)$_prompt_cmd_duration
	echo -ne " "
	echo -ne (set_color white)$prompt_char(set_color normal)
	echo -ne " "
end

function prompt_postexec --on-event fish_postexec
	set --erase _prompt_cmd_duration
	test "$CMD_DURATION" -lt 1000 && return

	set secs (math --scale=1 $CMD_DURATION/1000 % 60)
	set mins (math --scale=0 $CMD_DURATION/60000 % 60)
	set hours (math --scale=0 $CMD_DURATION/3600000)

	set out " "
	test $hours -gt 0; and set out "$out$hours""h"
	test $mins -gt 0; and set out "$out$mins""m"
	test $secs -gt 0; and set out "$out$secs""s"

	set --global _prompt_cmd_duration $out
end
