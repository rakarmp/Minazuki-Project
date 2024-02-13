#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

moddir="/data/adb/modules/MP"

Android="$(getprop ro.build.version.release)"

# Load lib
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/common"
. "$BASEDIR/profiles"

# ----------------------
# Info
# ----------------------
echo "# ----------------------" >> "$log"
echo "# Minazuki Project™" >> "$log"
echo "# Build Date: 02.12.2024" >> "$log"
echo "# Author: Zyarexx @Telegram" >> "$log"
echo "# ----------------------\n" >> "$log"

# ----------------------
# Main script
# ----------------------

# Kernel Panic
for panicoff in /proc/sys/kernel; do
    write "$panicoff/panic" "0"
    write "$panicoff/panic_on_oops" "0"
    write "$panicoff/panic_on_warn" "0"
    write "$panicoff/panic_on_rcu_stall" "0"
    write "$panicoff/softlockup_panic" "0"
    write "$panicoff/nmi_watchdog" "0"
done

for kernel in /sys/module/kernel; do
    write "$panicoff/parameters/panic" "0"
    write "$panicoff/parameters/panic_on_warn" "0"
    write "$panicoff/parameters/pause_on_oops" "0"
    write "$panicoff/panic_on_rcu_stall" "0"
done

# Disable CRC
for crc in /sys/module/mmc_core/parameters; do
    write "$crc/use_spi_crc" "0"
    write "$crc/removable" "N"
    write "$crc/crc" "N"
done

# Tcp tune
sysctl -w net.ipv4.tcp_ecn="1"
sysctl -w net.ipv4.tcp_no_metrics_save="1"
sysctl -w net.ipv4.tcp_fastopen="3"
sysctl -w net.ipv4.tcp_syncookies="1"
sysctl -w net.ipv4.tcp_timestamps="0"
sysctl -w net.ipv4.tcp_tw_reuse="1"
sysctl -w net.ipv4.tcp_sack="1"

# FileSystem
for fs in /proc/sys/fs; do
    write "$fs/dir-notify-enable" "0"
    write "$fs/lease-break-time" "15"
    write "$fs/leases-enable" "1"
done

# CPUSet
for cpu_set in /dev/cpuset; do
    write "$cpu_set/cpus" "0-7"
    write "$cpu_set/effective_cpus" "0-7"
    write "$cpu_set/background/cpus" "0-1"
    write "$cpu_set/background/effective_cpus" "0-1"
    write "$cpu_set/system-background/cpus" "0-2"
    write "$cpu_set/system-background/effective_cpus" "0-2"
    write "$cpu_set/foreground/cpus" "0-7"
    write "$cpu_set/foreground/effective_cpus" "0-7"
    write "$cpu_set/top-app/cpus" "0-7"
    write "$cpu_set/top-app/effective_cpus" "0-7"
    write "$cpu_set/restricted/cpus" "0-1"
    write "$cpu_set/restricted/effective_cpus" "0-3"
    write "$cpu_set/camera-daemon/cpus" "0-3"
    write "$cpu_set/camera-daemon/effective_cpus" "0-3"
    write "$cpu_set/camera-daemon-dedicated/cpus" "0-3"
    write "$cpu_set/camera-daemon-dedicated/effective_cpus" "0-3"
    write "$cpu_set/audio-app/cpus" "0-1"
done

# Blkio
if [[ -d "/dev/blkio" ]]; then
    write "/dev/blkio/blkio.weight" "1000"
    write "/dev/blkio/background/blkio.weight" "200"
    write "/dev/blkio/blkio.group_idle" "2000"
    write "/dev/blkio/background/blkio.group_idle" "0"
fi

# Uclamp
if [[ -e "/dev/stune/top-app/uclamp.max" ]]; then
    for top_app in /dev/cpuset/*/top-app; do
        write "$top_app/uclamp.max" "max" 
        write "$top_app/uclamp.min" "10"
        write "$top_app/uclamp.boosted" "1"
        write "$top_app/uclamp.latency_sensitive" "1"
    done
    for foreground in /dev/cpuset/*/foreground; do
        write "$foreground/uclamp.max" "50"
        write "$foreground/uclamp.min" "0"
        write "$foreground/uclamp.boosted" "0"
        write "$foreground/uclamp.latency_sensitive" "0"
    done
    for background in /dev/cpuset/*/background; do
        write "$background/uclamp.max" "max"
        write "$background/uclamp.min" "20"
        write "$background/uclamp.boosted" "0"
        write "$background/uclamp.latency_sensitive" "0"
    done
    for system_background in /dev/cpuset/*/system-background; do
        write "$system_background/uclamp.max" "40"
        write "$system_background/uclamp.min" "0"
        write "$system_background/uclamp.boosted" "0"
        write "$system_background/uclamp.latency_sensitive" "0"
    done
fi

# Disable LMP
for lpm in /sys/module/lpm_levels/system/*/*/*/; do
    if [[ -d "/sys/module/lpm_levels" ]]; then
        write "/sys/module/lpm_levels/parameters/lpm_prediction" "N"
        write "/sys/module/lpm_levels/parameters/lpm_ipi_prediction" "N"
        write "/sys/module/lpm_levels/parameters/sleep_disabled" "Y"
        write "$lpm/idle_enabled" "N"
        write "$lpm/suspend_enabled" "N"
    fi
done

# Kernel Debugging & logs
for i in debug_mask log_level* debug_level* *debug_mode edac_mc_log* enable_event_log *log_level* *log_ue* *log_ce* log_ecn_error snapshot_crashdumper seclog* compat-log *log_enabled tracing_on mballoc_debug sched_schedstats exception-trace; do
    for o in $(find /sys/ -type f -name "$i"); do
        write "$o" "0"
    done
done

# Disable Printk
write "/proc/sys/kernel/printk" "0 0 0 0"

# DDR boost
for devfreq in /sys/class/devfreq; do
    for dir in $devfreq/*cpubw $devfreq/*gpubw $devfreq/*llccbw $devfreq/*cpu-cpu-llcc-bw $devfreq/*cpu-llcc-ddr-bw $devfreq/*cpu-llcc-lat $devfreq/*llcc-ddr-lat $devfreq/*cpu-ddr-latfloor $devfreq/*cpu-l3-lat $devfreq/*cdsp-l3-lat $devfreq/*cdsp-l3-lat $devfreq/*cpu-ddr-qoslat $devfreq/*bpu-ddr-latfloor $devfreq/*snoc_cnoc_keepalive; do
        lock_val "9999000000" "$dir/max_freq" 
        lock_val "0" "$dir/min_freq"
    done
done
for l3c in DDR LLCC L3; do
        lock_val "9999000000" "/sys/devices/system/cpu/bus_dcvs/$l3c/*/max_freq"
done

# Disable Fsync & disable CRC
if [[ -f "/sys/module/sync/parameters/fsync_enabled" ]]; then
    write "/sys/module/sync/parameters/fsync_enabled" "N"
fi

# Disable ramdumps
write "/sys/module/subsystem_restart/parameters/enable_ramdumps" "0"
write "/sys/module/subsystem_restart/parameters/enable_mini_ramdumps" "0"

# Report max frequency to unity tasks
if [[ -e "/proc/sys/kernel/sched_lib_mask_force" ]] && [[ -e "/proc/sys/kernel/sched_lib_name" ]]; then
	write "/proc/sys/kernel/sched_lib_name" "UnityMain,libunity.so"
	write "/proc/sys/kernel/sched_lib_mask_force" "255"
fi

# Unity big little trick
for cpuinfo in /sys/devices/system/cpu/cpu[0-7]; do
    chmod 000 "$cpuinfo/cpufreq/cpuinfo_max_freq"
    chmod 000 "$cpuinfo/cpu_capacity"
    chmod 000 "$cpuinfo/topology/physical_package_id"
done

# Gpu tuner force on
su -c cmd settings put global GPUTUNER_SWITCH "true"

# Force game driver
package_filter="cut -f 2 -d ":""
line_row_filter="tail -1"

list="com.miHoYo.|com.mobile.legends|com.primatelabs.geekbench6|com.percent.royaldice|com.riotgames|DriftRacing|com.supercell.brawlstars|apexlegendsmobile|com.roblox.client|com.activision.callofduty.shooter|com.pubg.imobile|ent.criticalops|com.axlebolt.standoff|io.anuke.mindustry|com.wb.goog.mkx|com.supercell.clashroyale|com.carxtech.sr|com.netease.wotb|com.tencent.tmgp.sgame|com.tencent.lolm|com.garena.game.kgtw|com.futuremark.dmandroid.application|com.carxtech.carxdr2|com.tencent.ig|com.tap4fun.ape.gplay|com.gof.global|net.wargaming.wot.blitz|com.riotgames.league.wildrift|com.blizzard.diablo.immortal|com.foursakenmedia.wartortoise2|com.mechanist.poi|com.olzhas.carparking.multyplayer|au.com.metrotrains.beansholiday|com.playside.dwtd6|com.playside.dwtd3|com.matteljv.uno|com.popreach.dumbways|air.au.com.metro.DumbWaysToDie2"

games="$(pm list packages | $package_filter | egrep "$list" | tr '\n' ' ' | tr ' ' ',' | sed 's/,*$//g')"

# Old Game driver
if [[ "$Android" == "10" ]]; then
    # Restore game driver apps
    settings put global game_driver_opt_in_apps ""
    
    # Set Gaming driver
    settings put global game_driver_opt_in_apps "$games"
fi

# New Game driver
if [[ "$Android" -gt "10" ]]; then
    # Restore game driver apps
    settings put global updatable_driver_all_apps "0"
    settings put global updatable_driver_production_opt_in_apps ""

    # Set Gaming driver
    settings put global updatable_driver_production_opt_in_apps "$games"
fi

# Apply default profile
apply_all_tune

# Cgroups opt
pin_proc_on_perf "composer"
pin_proc_on_all "surfaceflinger"

# End
