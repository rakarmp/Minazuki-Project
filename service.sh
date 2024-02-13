#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

MODDIR=${0%/*}
script_dir="$MODDIR/script"

wait_until_login() {
    while [[ ! -d "/sdcard/Android" ]]; do
        sleep 1
    done

    local test_file="/sdcard/Android/.PERMISSION_TEST"
    touch "$test_file"
    while [[ ! -f "$test_file" ]]; do
        touch "$test_file"
        sleep 1
    done
    rm "$test_file"
}

wait_until_login

# Clear log
[[ -f "/sdcard/Minazuki.log" ]] || [[ -f "/sdcard/Documents/Minazuki/Minazuki.log" ]] && {
    [[ -f "/sdcard/Minazuki.log" ]] && {
        rm -rf "/sdcard/Minazuki.log" && log="/sdcard/Minazuki/Minazuki.log"
    } || [[ -f "/sdcard/Documents/Minazuki/Minazuki.log" ]] && {
        rm -rf "/sdcard/Documents/Minazuki/Minazuki.log" && log="/sdcard/Documents/Minazuki/Minazuki.log"
    }
}

tweaks
sleep 1
automode

# Notif
su -lp 2000 -c "cmd notification post -S bigtext -t 'Minazuki Project™' 'Tag' 'Thanks For You Use Minazuki Project'" > /dev/null 2>&1

# End
