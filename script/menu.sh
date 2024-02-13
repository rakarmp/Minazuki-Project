#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

moddir="/data/adb/modules/MP"

if [[ ! -e "$moddir" ]]; then
    echo "[!] Minazuki Project module not detected!"
    exit 1
fi

# Load lib
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/profiles"

Android="$(getprop ro.build.version.release)"

# Browser's
yandexlite=com.yandex.browser.lite
google=
opera=com.opera.browser
chrome=com.android.chrome
yandex=com.yandex.browser
operagx=com.opera.gx
operamini=com.opera.mini.native
firefox=org.mozilla.firefox
firefoxfocus=org.mozilla.focus
duckduckgo=com.duckduckgo.mobile.android
orbitum=com.orbitum.browser
ucturbo=com.ucturbo
atom=ru.mail.browser

# Color text
blue='\e[1;34m' > /dev/null 2>&1;
green='\e[1;32m' > /dev/null 2>&1;
purple='\e[1;35m' > /dev/null 2>&1;
cyan='\e[1;36m' > /dev/null 2>&1;
red='\e[1;31m' > /dev/null 2>&1;
white='\e[1;37m' > /dev/null 2>&1;
yellow='\e[01;33m' > /dev/null 2>&1;
cafe='\e[0;33m' > /dev/null 2>&1;
black='\e[30;1m' > /dev/null 2>&1;

# Background color
greenbg='\e[0;102m' > /dev/null 2>&1;
yellowbg='\e[0;103m' > /dev/null 2>&1;
redbg='\e[0;101m' > /dev/null 2>&1;

# Reset color
resetclr='\e[0m' > /dev/null 2>&1;

clear

# ----------------------
# MENU
# ----------------------
echo ""
echo -e $white 'MINAZUKI PROJECT'

sleep 1

clear

menu() {
    echo -e $yellowbg$black" Options "$resetclr
    echo ""
    echo ""
    echo -e $redbg$white" Profiles "$resetclr
    echo ""
    echo -e $white"[1] --> Open Profiles"
    echo ""
    echo ""
    echo -e $redbg$white" Cleaner "$resetclr
    echo ""
    echo -e $white"[2] --> Open Cleaner"
    echo ""
    echo ""
    echo -e $redbg$white" Game driver feature "$resetclr
    echo ""
    echo -e $white"[3] --> Open Game driver feature"
    echo ""
    echo ""
    echo -e $yellowbg$black" Write [number/word] for select option: "$resetclr
    echo ""
    echo ""
    echo -e $redbg$white" Group | Chat | Support "$resetclr
    echo ""
    echo -e $white"[Info] --> Source"
    echo ""
    echo ""
    sleep 0.1
    echo -e $blue"[0] Exit"$resetclr
    echo ""
    read main
    case ${main} in
    1)
        mode="$(getprop persist.minazuki.mode)"
        clear
        echo -e $red"Loading"; sleep 0.2; clear;
        echo -e $red"Loading."; sleep 0.2; clear;
        echo -e $red"Loading.."; sleep 0.2; clear;
        echo -e $red"Loading..."; sleep 0.2; clear;
        sleep 0.2
        echo -e $redbg$white" Select Profile "$resetclr
        echo ""
        echo ""
        echo -e $white"Current Profile Mode: $green$mode"$resetclr
        echo ""
        echo ""
        echo -e $white"[1] --> Balanced"
        echo ""
        echo -e $white"[2] --> Performance"
        echo ""
        echo -e $white"[3] --> Powersave"
        echo ""
        echo ""
        echo ""
        echo -e $red"[0] Back to menu"$resetclr
        echo ""
        read profiles
        case ${profiles} in
        1)
            clear
            echo -e $red"Applying Balanced"; sleep 0.2; clear;
            echo -e $red"Applying Balanced."; sleep 0.2; clear;
            echo -e $red"Applying Balanced.."; sleep 0.2; clear;
            echo -e $red"Applying Balanced..."; sleep 0.2;
    
            setprop persist.minazuki.mode "Balanced"

            apply_all_tune > /dev/null 2>&1

            clear
            echo -e $green"Complete!"
            su -lp 2000 -c "cmd notification post -S bigtext -t 'The profile was successfully applied.' 'Tag' 'Current: Balanced'" > /dev/null 2>&1
            sleep 1
            clear
            menu
        ;;
        2)
            clear
            echo -e $red"Applying Performance"; sleep 0.2; clear;
            echo -e $red"Applying Performance."; sleep 0.2; clear;
            echo -e $red"Applying Performance.."; sleep 0.2; clear;
            echo -e $red"Applying Performance..."; sleep 0.2;

            setprop persist.minazuki.mode "Performance"

            apply_all_tune > /dev/null 2>&1

            clear
            echo -e $green"Complete! "
            su -lp 2000 -c "cmd notification post -S bigtext -t 'The profile was successfully applied.' 'Tag' 'Current: Performance'" > /dev/null 2>&1
            sleep 1
            clear
            menu
        ;;
        3)
            clear
            echo -e $red"Applying Powersave"; sleep 0.2; clear;
            echo -e $red"Applying Powersave."; sleep 0.2; clear;
            echo -e $red"Applying Powersave.."; sleep 0.2; clear;
            echo -e $red"Applying Powersave..."; sleep 0.2;

            setprop persist.minazuki.mode "Powersave"

            apply_all_tune > /dev/null 2>&1

            clear
            echo -e $green"Complete!"
            su -lp 2000 -c "cmd notification post -S bigtext -t 'The profile was successfully applied.' 'Tag' 'Current: Powersave'" > /dev/null 2>&1
            sleep 1
            clear
            menu
        ;;
        0)
            clear
            echo -e $white"Back to menu"
            clear
            echo -e $green"Okay!"; sleep 1;
            clear
            menu
        ;;
        *) 
            clear
            echo -e $red"Response error, opening menu again..."; sleep 1;
            clear
            menu
        ;;
        esac
    ;;
    2)
        clear
        echo -e $red"Loading"; sleep 0.2; clear;
        echo -e $red"Loading."; sleep 0.2; clear;
        echo -e $red"Loading.."; sleep 0.2; clear;
        echo -e $red"Loading..."; sleep 0.2; clear;
        echo -e $redbg$white" Cleaner "$resetclr
        echo ""
        echo ""
        echo -e $white"[1] --> Clear cache"
        echo ""
        echo ""
        echo ""
        echo -e $red"[0] Back to menu"
        echo ""
        echo -e $white""
        read cache
        case ${cache} in
        1)
            clear
            echo -e $red"Clear cache"; sleep 0.2; clear;
            echo -e $red"Clear cache."; sleep 0.2; clear;
            echo -e $red"Clear cache.."; sleep 0.2; clear;
            echo -e $red"Clear cache..."; sleep 0.2;
            find /storage/emulated/0/Android/data/*/cache/* -delete &>/dev/null
            find /data/ -name code_cache -delete &>/dev/null
            find /data/data/*/cache/* -delete &>/dev/null
            find /sdcard/Android/data/*/cache/* -delete &>/dev/null
            sleep 0.5
            clear
            echo -e $green"Complete!"
            su -lp 2000 -c "cmd notification post -S bigtext -t 'The cache was successfully clear.' 'Tag' ''🗑️" > /dev/null 2>&1
            sleep 1
            clear
            menu
        ;;
        0)
            clear
            echo -e $white"Back to menu"
            clear
            echo -e $green"Okay! "; sleep 1;
            clear
            menu
        ;;
        *) 
            clear
            echo -e $red"Response error, opening menu again..."; sleep 1;
            clear
            menu
        ;;
        esac
    ;;
    3)
        clear
        echo -e $red"Loading"; sleep 0.2; clear;
        echo -e $red"Loading."; sleep 0.2; clear;
        echo -e $red"Loading.."; sleep 0.2; clear;
        echo -e $red"Loading..."; sleep 0.2; clear;
        echo -e $redbg$white" Angle driver feature "$resetclr
        echo ""
        echo -e $yellowbg$black"Recommendation: Compatible with android 11 and above."$resetclr
        echo -e $yellowbg$black"After application, the phone will restart automatically."$resetclr
        echo ""
        echo -e $white"Your version android: $green$Android"$resetclr
        echo ""
        echo ""
        echo -e $white"[1] --> Activate Angle driver"
        echo ""
        echo -e $white"[2] --> Disable Angle driver"
        echo ""
        echo ""
        echo ""
        echo -e $red"[0] Back to menu"
        echo ""
        echo -e $white""
        read driver
        case ${driver} in
        1)
            clear
            echo -e $red"Activate"; sleep 0.2; clear;
            echo -e $red"Activate."; sleep 0.2; clear;
            echo -e $red"Activate.."; sleep 0.2; clear;
            echo -e $red"Activate..."; sleep 0.2;
        
            package_filter="cut -f 2 -d ":""
            line_row_filter="tail -1"

            list="com.miHoYo.|com.mobile.legends|com.primatelabs.geekbench6|com.percent.royaldice|com.riotgames|DriftRacing|com.supercell.brawlstars|apexlegendsmobile|com.roblox.client|com.activision.callofduty.shooter|com.pubg.imobile|ent.criticalops|com.axlebolt.standoff|io.anuke.mindustry|com.wb.goog.mkx|com.supercell.clashroyale|com.carxtech.sr|com.netease.wotb|com.tencent.tmgp.sgame|com.tencent.lolm|com.garena.game.kgtw|com.futuremark.dmandroid.application|com.carxtech.carxdr2|com.tencent.ig|com.tap4fun.ape.gplay|com.gof.global|net.wargaming.wot.blitz|com.riotgames.league.wildrift|com.blizzard.diablo.immortal|com.foursakenmedia.wartortoise2|com.mechanist.poi|com.olzhas.carparking.multyplayer|au.com.metrotrains.beansholiday|com.playside.dwtd6|com.playside.dwtd3|com.matteljv.uno|com.popreach.dumbways|air.au.com.metro.DumbWaysToDie2"

            games="$(pm list packages | $package_filter | egrep "$list" | tr '\n' ' ' | tr ' ' ',' | sed 's/,*$//g')"
        
            # Warrning
            if [[ "$Android" -lt "10" ]]; then
                clear
                echo $green"You version lower that 10, sorry."
                clear
                menu
            fi
        
            # Enable angle driver
            if [[ "$Android" -gt "11" ]]; then
                settings put global angle_gl_driver_selection_values "angle"
                settings put global angle_gl_driver_all_angle "0"
                settings put global angle_gl_driver_selection_package "$games"
                settings put global angle_debug_package "$games"
            fi
        
            clear

            # Notify
            echo -e $green"In order to finish the setup, reboot is needed" 
            echo -e -n $green"Reboot after 5 sec...!"

            # Pause 5 sec
            sleep 5

            # Reboot to apply modify upper
            svc power reboot
        
            sleep 0.5
            clear
            menu
        ;;
        2)
            clear
            echo -e $red"Disable"; sleep 0.2; clear;
            echo -e $red"Disable."; sleep 0.2; clear;
            echo -e $red"Disable.."; sleep 0.2; clear;
            echo -e $red"Disable..."; sleep 0.2;
        
            # Disable Angle driver
            if [[ "$Android" -gt "11" ]]; then
                settings delete global angle_gl_driver_selection_values
                settings delete global angle_gl_driver_all_angle
                settings delete global angle_gl_driver_selection_package
                settings delete global angle_debug_package
            fi
        
            clear
        
            echo -e $green"Complete!"
            sleep 0.5
            clear
            menu
        ;;
        0)
            clear
            echo -e $white"Back to menu"
            clear
            echo -e $green"Okay! "; sleep 1;
            clear
            menu
        ;;
        *) 
            clear
            echo -e $red"Response error, opening menu again..."; sleep 1;
            clear
            menu
        ;;
        esac
    ;;
    "Info" | "info")
        clear
        echo -e $red"Loading"; sleep 0.2; clear;
        echo -e $red"Loading."; sleep 0.2; clear;
        echo -e $red"Loading.."; sleep 0.2; clear;
        echo -e $red"Loading..."; sleep 0.2; clear;
        echo -e $redbg$white"Infomation"$resetclr
        echo ""
        echo ""
        echo -e $white"[1] --> Open the Chat | Support in telegram"
        echo ""
        echo -e $white"[2] --> Open the Updates group in telegram"
        echo ""
        echo ""
        echo ""
        echo -e $red"[0] Back to menu"
        echo ""
        echo -e $white ""
        read info
        case ${info} in
        1)
            clear
            for browser in ${yandex} ${yandexlite} ${chrome} ${google} ${opera} ${operagx} ${operamini} ${firefox} ${firefoxfocus} ${orbitum} ${ucturbo} ${duckduckgo} ${atom}; do
            am start -p ${browser} -a android.intent.action.VIEW -d https://t.me/Zyarexx > /dev/null 2>&1
            done
            clear
            exit 0
        ;;
        2)
            clear
            for browser in ${yandex} ${yandexlite} ${chrome} ${google} ${opera} ${operagx} ${operamini} ${firefox} ${firefoxfocus} ${orbitum} ${ucturbo} ${duckduckgo} ${atom}; do
            am start -p ${browser} -a android.intent.action.VIEW -d https://t.me/rexxProject > /dev/null 2>&1
            done
            clear
            exit 0
        ;;
        0)
            clear
            echo -e $white"Back to menu"
            clear
            echo -e $green"Okay! "; sleep 1;
            clear
            menu
        ;;
        *) 
            clear
            echo -e $red"Response error, opening menu again..."; sleep 1;
            clear
            menu
        ;;
        esac
    ;;
    0) 
        clear
        echo -n $green"Bye Madafaka! "$resetclr; sleep 1;
        exit 0
    ;;
    *) 
        clear
        echo -e $red"Response error, opening menu again... "; sleep 1;
        clear
        menu
    ;;
    esac
}

# Start Menu
menu

# End
