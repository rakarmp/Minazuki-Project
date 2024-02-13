#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

# For debug purposes
[[ "$1" == "-d" ]] || [[ "$1" == "--debug" ]] && set -x

moddir="/data/adb/modules/MP"

# Load lib
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/common"
. "$BASEDIR/profiles"

echo "# ----------------------" >> "$log"
echo "# Automode" >> "$log"
echo "# ----------------------\n" >> "$log"

# Filter
list_unified_filter="grep -o -e com.StudioFurukawa. -e com.tencent.mf.uam -e com.gaijin.xom -e ting.action.pvp -e ite.sgameGlobal -e com.dts.freefire -e squareenix.lis -e com.nekki.shadowfight3 -e walkingdead -e headedshark.tco -e com.tiramisu. -e com.infinityvector.assolutoracing -e n.c1game.naslim -e com.gamedevltd. -e com.madfingergames. -e cade.next.mrglo -e com.netease.ddsfna -e com.carxtech. -e DriftRacing -e omin.protectors -e com.sozap. -e com.panzerdog. -e com.firsttouchgames.dls -e ent.criticalops -e flightsimulator -e com.riotgames. -e com.garena.game. -e com.tencent.lolm -e com.tencent.tmgp. -e com.mobile.legends -e com.tencent.tmgp. -e com.miHoYo. -e com.ngame.allstar.eu -e callofdutyshooter -e com.axlebolt.standoff -e com.tencent.ig -e com.netease.jddsaef -e com.netease.g93na -e apexlegendsmobile -e com.pubg.imobile -e com.netease.mrzhna -e hotta. -e dw.h5yvzr.yt -e com.roblox.client -e com.supercell.brawlstars -e com.percent.royaldice -e com.primatelabs.geekbench5 -e com.primatelabs.geekbench6 -e com.futuremark.dmandroid.application -e com.activision.callofduty.shooter -e io.anuke.mindustry -e com.wb.goog.mkx -e com.supercell.clashroyale -e com.carxtech.sr -e com.netease.wotb -e com.tencent.tmgp.sgame -e com.garena.game.kgtw -e com.carxtech.carxdr2 -e com.tap4fun.ape.gplay -e com.gof.global -e net.wargaming.wot.blitz -e com.riotgames.league.wildrift -e com.blizzard.diablo.immortal -e com.foursakenmedia.wartortoise2 -e com.mechanist.poi -e com.olzhas.carparking.multyplayer -e au.com.metrotrains.beansholiday -e com.playside.dwtd6 -e com.playside.dwtd3 -e com.matteljv.uno -e com.popreach.dumbways -e com.popreach.dumbways -e air.au.com.metro.DumbWaysToDie2"

line_row_filter="tail -1"
package_filter="cut -f 2 -d ":""

# Variables
scrn_on=none

get_scrn_state() {
	scrn_state="$(dumpsys power 2>/dev/null | grep state=O | cut -d "=" -f 2)"
	[[ "$scrn_state" == "" ]] && scrn_state="$(dumpsys window policy | grep screenState | awk -F '=' '{print $2}')"
	[[ "$scrn_state" == "OFF" ]] && scrn_on=0 || scrn_on=1
	[[ "$scrn_state" == "SCREEN_STATE_OFF" ]] && scrn_on=0 || scrn_on=1
}

(
    while true; do
        sleep 60
        
        # Find window / game function
        window="$(dumpsys window | grep -E 'mCurrentFocus|mFocusedApp' | $list_unified_filter | $line_row_filter)"
        game="$(pm list package | $package_filter | grep "$window")"
        
        # Get current screen state Off/On
        get_scrn_state
        
        # Main
        if [[ "$window" ]]; then
            if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
                sync
                echo "$(date "+[%F - %H:%M]") [🎮] The user is in the $game, Gaming On" >> "$log"
                setprop minazuki.mode "Gaming"
                apply_all_tune
            fi
        elif [[ ! "$window" ]]; then
            if [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
                sync
                echo "$(date "+[%F - %H:%M]") [✨] Balanced On" >> "$log"
                setprop minazuki.mode "Balanced"
                apply_all_tune
            fi
        fi
    done
) &

(
    while true; do
        [[ "$(getprop minazuki.mode)" != "Sleeping" ]] && sleep 300 || sleep 5
        
        # Get current screen state Off/On
        get_scrn_state

        if [[ "$scrn_on" == "1" ]] && [[ "$(getprop minazuki.mode)" == "Sleeping" ]] && [[ "$(getprop minazuki.mode)" != "Powersave" ]]; then
            sync
            echo "$(date "+[%F - %H:%M]") [✨] Device wake up, Balanced On" >> "$log"
            setprop minazuki.mode "Balanced"
            apply_all_tune
        elif [[ "$scrn_on" == "0" ]] && [[ "$(getprop minazuki.mode)" != "Sleeping" ]]; then
            sync
            echo "$(date "+[%F - %H:%M]") [🔋] Device sleep, Powersave On" >> "$log"
            setprop minazuki.mode "Sleeping"
            apply_all_tune
        fi
    done
) &