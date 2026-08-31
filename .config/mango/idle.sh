
swayidle \
    timeout 1200 'systemctl suspend' \
    timeout 5 'light -S 30' \
    resume 'light -S 100'
