#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

# Maximum unsigned integer size in C
UINT_MAX="4294967295"

# Duration in nanoseconds of one scheduling period
sched_period_balanced="$((4 * 1000 * 1000))"
sched_period_battery="$((5 * 1000 * 1000))"
sched_period_performance="$((10 * 1000 * 1000))"

# How many tasks should we have at a maximum in one scheduling period
sched_tasks_balanced="8"
sched_tasks_battery="5"
sched_tasks_performance="6"

# ----------------------
# Basic 
# ----------------------

write() {
    # Bail out if file does not exist
    if [[ ! -e "$1" ]]; then
        echo "❗Not found $1"
        return 1
    fi
    
    current="$(cat $1)"
    
    # Make file writable in case it is not already
    chmod +w "$1" 2> /dev/null
    
    # Write the new value
    echo -n "$2" > "$1" 2> /dev/null
    
    # Bail out if write fails
    if [[ $? -ne 0 ]]; then
        echo "❗Failed set $2 to $1"
    return 1
    fi
    
    echo "Success: $current --> $2 $1"
    
    # Guide: Write $2 = Value | $1 = Task/Directory
}

lock_val() {
    if [[ -f "$2" ]]; then
        chown root:root "$2" 2> /dev/null
        chmod 0666 "$2" 2> /dev/null
        echo "$1" > "$2"
        chmod 0444 "$2" 2> /dev/null
    fi
}

# ----------------------
# Cgroups
# ----------------------

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_task_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			echo "$temp_tid" >"/dev/$3/$2/tasks"
		done
	done
}

# $1:process_name $2:cgroup_name $3:"cpuset"/"stune"
change_proc_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		comm="$(cat "/proc/$temp_pid/comm")"
		echo "$temp_pid" >"/dev/$3/$2/cgroup.procs"
	done
}

# $1:task_name $2:thread_name $3:cgroup_name $4:"cpuset"/"stune"
change_thread_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && echo "$temp_tid" >"/dev/$4/$3/tasks"
		done
	done
}

# $1:task_name $2:cgroup_name $3:"cpuset"/"stune"
change_main_thread_cgroup() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		comm="$(cat "/proc/$temp_pid/comm")"
		echo "$temp_pid" >"/dev/$3/$2/tasks"
	done
}

# $1:task_name $2:hex_mask(0x00000003 is CPU0 and CPU1)
change_task_affinity() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			taskset -p "$2" "$temp_tid"
		done
	done
}

# $1:task_name $2:thread_name $3:hex_mask(0x00000003 is CPU0 and CPU1)
change_thread_affinity() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && taskset -p "$3" "$temp_tid"
		done
	done
}

# $1:task_name $2:hex_mask(0x00000003 is CPU0 and CPU1)
change_other_thread_affinity() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls /proc/"$temp_pid"/task/); do
			comm="$(cat /proc/"$temp_pid"/task/*/comm)"
			[[ ! "$uni_task" == "$comm" ]] && [[ ! "$uni_task2" == "$comm" ]] && [[ ! "$etc_task" == "$comm" ]] && [[ ! "$render_task" == "$comm" ]] && [[ ! "$render_task2" == "$comm" ]] && taskset -p "$2" "$temp_tid"
		done
	done
}

# $1:task_name $2:nice(relative to 120)
change_task_nice() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			renice -n +40 -p "$temp_tid"
			renice -n -19 -p "$temp_tid"
			renice -n "$2" -p "$temp_tid"
		done
	done
}

# $1:task_name $2:thread_name $3:nice(relative to 120)
change_thread_nice() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && {
				renice -n +40 -p "$temp_tid"
				renice -n -19 -p "$temp_tid"
				renice -n "$3" -p "$temp_tid"
			}
		done
	done
}

# $1:task_name $2:priority(99-x, 1<=x<=99) (SCHED_RR)
change_task_rt() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			chrt -p "$temp_tid" "$2"
		done
	done
}

# $1:task_name $2:priority(99-x, 1<=x<=99) (SCHED_FIFO)
change_task_rt_ff() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			chrt -f -p "$temp_tid" "$2"
		done
	done
}

# $1:task_name $2:thread_name $3:priority(99-x, 1<=x<=99)
change_thread_rt() {
	for temp_pid in $(echo "$ps_ret" | grep -i -E "$1" | awk '{print $1}'); do
		for temp_tid in $(ls "/proc/$temp_pid/task/"); do
			comm="$(cat "/proc/$temp_pid/task/$temp_tid/comm")"
			[[ "$(echo "$comm" | grep -i -E "$2")" != "" ]] && chrt -p "$3" "$temp_tid"
		done
	done
}

# $1:task_name
change_task_high_prio() { change_task_nice "$1" "-20"; }

# $1:task_name $2:thread_name
change_thread_high_prio() { change_thread_nice "$1" "$2" "-20"; }

unpin_thread() { change_thread_cgroup "$1" "$2" "" "cpuset"; }

# 0-3
pin_thread_on_pwr() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "0f"
}

# 0-6
pin_thread_on_mid() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "7f"
}

# 4-7
pin_thread_on_perf() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "f0"
}

# 0-7
pin_thread_on_all() {
	unpin_proc "$1"
	change_task_affinity "$1" "ff"
}

# $1:task_name $2:thread_name $3:hex_mask
pin_thread_on_custom() {
	unpin_thread "$1" "$2"
	change_thread_affinity "$1" "$2" "$3"
}

# $1:task_name $2:hex_mask
pin_other_thread_on_custom() {
	unpin_thread "$1" "$2"
	change_other_thread_affinity "$1" "$2"
}

# $1:task_name
unpin_proc() { change_task_cgroup "$1" "" "cpuset"; }

# 0-3
pin_proc_on_pwr() {
	unpin_proc "$1"
	change_task_affinity "$1" "0f"
}

# 0-6
pin_proc_on_mid() {
	unpin_proc "$1"
	change_task_affinity "$1" "7f"
}

# 4-7
pin_proc_on_perf() {
	unpin_proc "$1"
	change_task_affinity "$1" "f0"
}

# 0-7
pin_proc_on_all() {
	unpin_proc "$1"
	change_task_affinity "$1" "ff"
}

# $1:task_name $2:hex_mask
pin_proc_on_custom() {
	unpin_proc "$1"
	change_task_affinity "$1" "$2"
}

rebuild_ps_cache() { ps_ret="$(ps -Ao pid,args)"; }

# ----------------------
# Main
# ----------------------

# Logs folder
if [[ ! -d "/sdcard/Documents" ]]; then
    log="/sdcard/Minazuki.log"
else
    if [[ ! -d "/sdcard/Documents/Minazuki" ]]; then
        mkdir "/sdcard/Documents/Minazuki"
        log="/sdcard/Documents/Minazuki/Minazuki.log"
    else
        log="/sdcard/Documents/Minazuki/Minazuki.log"
    fi
fi

# Gpu find
if [[ -d "/sys/class/kgsl/kgsl-3d0" ]]; then
    gpu="/sys/class/kgsl/kgsl-3d0"
	qcom=true
fi

for gpul2 in /sys/devices/*.mali; do
	if [[ -d "$gpul2" ]]; then
		gpu="$gpul2"
		qcom=false
	fi
done

for gpul3 in /sys/devices/platform/*.gpu; do
	if [[ -d "$gpul3" ]]; then
		gpu="$gpul3"
		qcom=false
	fi
done

for gpul4 in /sys/devices/platform/mali-*; do
	if [[ -d "$gpul4" ]]; then
		gpu="$gpul4"
		qcom=false
	fi
done

for gpul5 in /sys/devices/platform/*.mali; do
	if [[ -d "$gpul5" ]]; then
		gpu="$gpul5"
		qcom=false
	fi
done

for gpul6 in /sys/class/misc/mali*/device/devfreq/gpufreq; do
	if [[ -d "$gpul6" ]]; then
		gpu="$gpul6"
		qcom=false
	fi
done

for gpul7 in /sys/class/misc/mali*/device/devfreq/*.gpu; do
	if [[ -d "$gpul7" ]]; then
		gpu="$gpul7"
		qcom=false
	fi
done

for gpul8 in /sys/devices/platform/*.mali/misc/mali0; do
	if [[ -d "$gpul8" ]]; then
		gpu="$gpul8"
		qcom=false
	fi
done

for gpul9 in /sys/devices/platform/mali.*; do
	if [[ -d "$gpul9" ]]; then
		gpu="$gpul9"
		qcom=false
	fi
done

for gpul10 in /sys/devices/platform/*.mali/devfreq/*.mali/subsystem/*.mali; do
	if [[ -d "$gpul10" ]]; then
		gpu="$gpul10"
		qcom=false
	fi
done

for gpul11 in /sys/class/misc/mali*/device; do
	if [[ -d "$gpul11" ]]; then
		gpu="$gpul11"
		qcom=false
	fi
done

# Max GPU frequency
if [[ -e "$gpu/max_gpuclk" ]]; then
    gpu_max_freq="$(cat "$gpu/max_gpuclk")"
elif [[ -e "/sys/kernel/gpu/gpu_max_clock" ]]; then
    gpu_max_freq="$(cat "/sys/kernel/gpu/gpu_max_clock")"
fi

# Min GPU frequency
if [[ -e "$gpu/min_gpuclk" ]]; then
    gpu_min_freq="$(cat "$gpu/min_gpuclk")"
elif [[ -e "/sys/kernel/gpu/gpu_min_clock" ]]; then
    gpu_min_freq="$(cat "/sys/kernel/gpu/gpu_min_clock")"
fi

# Min GPU powerlevels
min_pwr="$(cat /sys/class/kgsl/kgsl-3d0/num_pwrlevels)"

# Convert mhz --> hz, hz --> mhz
if [[ "$gpu_max_freq" -ge "100000" ]]; then
    gpu_max_clk_mhz="$((gpu_max_freq / 1000))"
    gpu_min_clk_mhz="$((gpu_min_freq / 1000))"
elif [[ "$gpu_max_freq" -ge "100000000" ]]; then
    gpu_max_clk_mhz="$((gpu_max_freq / 1000000))"
    gpu_min_clk_mhz="$((gpu_min_freq / 1000000))"
elif [[ "$gpu_max_freq" -lt "100000" ]]; then
    gpu_max_clk_hz="$((gpu_max_freq * 1000))"
    gpu_min_clk_hz="$((gpu_min_freq * 1000))"
elif [[ "$gpu_max_freq" -lt "100000000" ]]; then
    gpu_max_clk_hz="$((gpu_max_freq * 1000000))"
    gpu_min_clk_hz="$((gpu_min_freq * 1000000))"
fi

# End
