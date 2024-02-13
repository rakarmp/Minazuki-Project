#!/system/bin/sh

# -------------------------
# Minazuki Project @Zyarexx
# -------------------------

# Load lib
BASEDIR="$(dirname $(readlink -f "$0"))"
. "$BASEDIR/common"

gpu_tune() {
    if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
    
        # Tune Gpu for Qcom
        if [[ "$qcom" == "true" ]]; then
            write "$gpu/throttling" "0"
            write "$gpu/devfreq/adrenoboost" "0"
            write "$gpu/min_pwrlevel" "$min_pwr"
            write "$gpu/devfreq/max_freq" "$gpu_max_clk_hz"
            write "$gpu/devfreq/min_freq" "$gpu_min_clk_hz"
        fi
        
        # Adreno idler
        if [[ -e "/sys/class/kgsl/kgsl-3d0/adreno_idler_active" ]]; then
            write "/sys/class/kgsl/kgsl-3d0/adreno_idler_active" "N"
        fi
        
    elif [[ "$(getprop minazuki.mode)" == "Performance" ]] || [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
    
        # Tune Gpu for Qcom
        if [[ "$qcom" == "true" ]]; then
            write "$gpu/throttling" "0"
            write "$gpu/devfreq/adrenoboost" "3"
            write "$gpu/min_pwrlevel" "$min_pwr"
            write "$gpu/devfreq/max_freq" "$gpu_max_clk_hz"
            write "$gpu/devfreq/min_freq" "$gpu_max_clk_hz"
        fi
        
        # Adreno idler
        if [[ -e "/sys/class/kgsl/kgsl-3d0/adreno_idler_active" ]]; then
            write "/sys/class/kgsl/kgsl-3d0/adreno_idler_active" "N"
        fi
        
    elif [[ "$(getprop minazuki.mode)" == "Powersave" ]] || [[ "$(getprop minazuki.mode)" == "Sleeping" ]]; then
    
        # Tune Gpu for Qcom
        if [[ "$qcom" == "true" ]]; then
            write "$gpu/throttling" "1"
            write "$gpu/devfreq/adrenoboost" "0"
            write "$gpu/min_pwrlevel" "3"
            write "$gpu/devfreq/max_freq" "$gpu_max_clk_hz"
            write "$gpu/devfreq/min_freq" "$gpu_min_clk_hz"
        fi
        
        # Adreno idler
        if [[ -e "/sys/class/kgsl/kgsl-3d0/adreno_idler_active" ]]; then
            write "/sys/class/kgsl/kgsl-3d0/adreno_idler_active" "N"
        fi
    fi
}

cpu_tune() {
    if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
    
        # Cpu governor advanced
        for cpugovernor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
            write "$cpugovernor/up_rate_limit_us" "500" 
            write "$cpugovernor/down_rate_limit_us" "20000"
            write "$cpugovernor/go_hispeed_load" "90"
        done
        
        for cpugovernor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
            write "$cpugovernor/up_rate_limit_us" "500" 
            write "$cpugovernor/down_rate_limit_us" "20000"
            write "$cpugovernor/go_hispeed_load" "90"
        done
        
        # All cores online
        for i in 0 1 2 3 4 5 6 7 8 9; do
            lock_val "1" "/sys/devices/system/cpu/cpu$i/online"
        done
        
    elif [[ "$(getprop minazuki.mode)" == "Performance" ]] || [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
    
        # Cpu governor advanced
        for cpugovernor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
            write "$cpugovernor/up_rate_limit_us" "500" 
            write "$cpugovernor/down_rate_limit_us" "24000"
            write "$cpugovernor/go_hispeed_load" "79"
        done
        
        for cpugovernor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
            write "$cpugovernor/up_rate_limit_us" "500" 
            write "$cpugovernor/down_rate_limit_us" "24000"
            write "$cpugovernor/go_hispeed_load" "79"
        done
        
        # All cores online
        for i in 0 1 2 3 4 5 6 7 8 9; do
            lock_val "1" "/sys/devices/system/cpu/cpu$i/online"
        done
        
    elif [[ "$(getprop minazuki.mode)" == "Powersave" ]] || [[ "$(getprop minazuki.mode)" == "Sleeping" ]]; then
    
        # Cpu governor advanced
        for cpugovernor in $(find /sys/devices/system/cpu/ -name *util* -type d); do
            write "$cpugovernor/up_rate_limit_us" "500" 
            write "$cpugovernor/down_rate_limit_us" "1000"
            write "$cpugovernor/go_hispeed_load" "90"
        done
        
        for cpugovernor in $(find /sys/devices/system/cpu/ -name *sched* -type d); do
            write "$cpugovernor/up_rate_limit_us" "500" 
            write "$cpugovernor/down_rate_limit_us" "1000"
            write "$cpugovernor/go_hispeed_load" "90"
        done
        
        # 4-* cores offline for Eco
        for i in 4 5 6 7 8 9; do
            lock_val "0" "/sys/devices/system/cpu/cpu$i/online"
        done
    fi
}

sched_tune() {
    if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
    
        for sched in /proc/sys/kernel; do
            write "$sched/perf_cpu_time_max_percent" "5"
            write "$sched/sched_autogroup_enabled" "1"
            write "$sched/sched_child_runs_first" "1"
            write "$sched/sched_tunable_scaling" "0"
            write "$sched/sched_latency_ns" "$sched_period_balanced"
            write "$sched/sched_min_granularity_ns" "$((sched_period_balanced / sched_tasks_balanced))"
            write "$sched/sched_wakeup_granularity_ns" "$((sched_period_balanced / 2))"
            write "$sched/sched_migration_cost_ns" "5000000"
            write "$sched/sched_nr_migrate" "32"
            write "$sched/sched_schedstats" "0"
            write "$sched/printk_devkmsg" "off"
        done
        
    elif [[ "$(getprop minazuki.mode)" == "Performance" ]] || [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
    
        for sched in /proc/sys/kernel; do
            write "$sched/perf_cpu_time_max_percent" "20"
            write "$sched/sched_autogroup_enabled" "0"
            write "$sched/sched_child_runs_first" "0"
            write "$sched/sched_tunable_scaling" "0"
            write "$sched/sched_latency_ns" "$sched_period_performance"
            write "$sched/sched_min_granularity_ns" "$((sched_period_performance / sched_tasks_performance))"
            write "$sched/sched_wakeup_granularity_ns" "$((sched_period_performance / 2))"
            write "$sched/sched_migration_cost_ns" "5000000"
            write "$sched/sched_nr_migrate" "128"
            write "$sched/sched_schedstats" "0"
            write "$sched/printk_devkmsg" "off"
        done
        
    elif [[ "$(getprop minazuki.mode)" == "Powersave" ]] || [[ "$(getprop minazuki.mode)" == "Sleeping" ]]; then
    
        for sched in /proc/sys/kernel; do
            write "$sched/perf_cpu_time_max_percent" "3"
            write "$sched/sched_autogroup_enabled" "1"
            write "$sched/sched_child_runs_first" "1"
            write "$sched/sched_tunable_scaling" "0"
            write "$sched/sched_latency_ns" "$sched_period_battery"
            write "$sched/sched_min_granularity_ns" "$((sched_period_battery / sched_tasks_battery))"
            write "$sched/sched_wakeup_granularity_ns" "$((sched_period_battery / 2))"
            write "$sched/sched_migration_cost_ns" "5000000"
            write "$sched/sched_nr_migrate" "4"
            write "$sched/sched_schedstats" "0"
            write "$sched/printk_devkmsg" "off"
        done
    fi
}

schedboost_tune() {
    if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
        write "/dev/stune/background/schedtune.boost" "0"
	    write "/dev/stune/background/schedtune.colocate" "0"
	    write "/dev/stune/background/schedtune.prefer_idle" "0"
	    write "/dev/stune/background/schedtune.sched_boost" "0"
	    write "/dev/stune/background/schedtune.sched_boost_no_override" "1"

	    write "/dev/stune/foreground/schedtune.boost" "0"
	    write "/dev/stune/foreground/schedtune.colocate" "0"
	    write "/dev/stune/foreground/schedtune.prefer_idle" "0"
	    write "/dev/stune/foreground/schedtune.sched_boost" "0"
	    write "/dev/stune/foreground/schedtune.sched_boost_no_override" "1"

	    write "/dev/stune/rt/schedtune.boost" "0"
		write "/dev/stune/rt/schedtune.colocate" "0"
		write "/dev/stune/rt/schedtune.prefer_idle" "0"
		write "/dev/stune/rt/schedtune.sched_boost" "0"
		write "/dev/stune/rt/schedtune.sched_boost_no_override" "1"

		write "/dev/stune/top-app/schedtune.boost" "1"
		write "/dev/stune/top-app/schedtune.colocate" "1"
		write "/dev/stune/top-app/schedtune.prefer_idle" "1"
		write "/dev/stune/top-app/schedtune.sched_boost" "0"
		write "/dev/stune/top-app/schedtune.sched_boost_no_override" "1"

		write "/dev/stune/schedtune.boost" "0"
		write "/dev/stune/schedtune.colocate" "0"
		write "/dev/stune/schedtune.prefer_idle" "0"
		write "/dev/stune/schedtune.sched_boost" "0"
		write "/dev/stune/schedtune.sched_boost_no_override" "0"
		
    elif [[ "$(getprop minazuki.mode)" == "Performance" ]] || [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
		
		write "/dev/stune/background/schedtune.boost" "0"
	    write "/dev/stune/background/schedtune.colocate" "0"
	    write "/dev/stune/background/schedtune.prefer_idle" "0"
	    write "/dev/stune/background/schedtune.sched_boost" "0"
	    write "/dev/stune/background/schedtune.sched_boost_no_override" "1"

	    write "/dev/stune/foreground/schedtune.boost" "0"
	    write "/dev/stune/foreground/schedtune.colocate" "0"
	    write "/dev/stune/foreground/schedtune.prefer_idle" "0"
	    write "/dev/stune/foreground/schedtune.sched_boost" "0"
	    write "/dev/stune/foreground/schedtune.sched_boost_no_override" "1"

	    write "/dev/stune/rt/schedtune.boost" "0"
		write "/dev/stune/rt/schedtune.colocate" "0"
		write "/dev/stune/rt/schedtune.prefer_idle" "0"
		write "/dev/stune/rt/schedtune.sched_boost" "0"
		write "/dev/stune/rt/schedtune.sched_boost_no_override" "1"

		write "/dev/stune/top-app/schedtune.boost" "60"
		write "/dev/stune/top-app/schedtune.colocate" "1"
		write "/dev/stune/top-app/schedtune.prefer_idle" "1"
		write "/dev/stune/top-app/schedtune.sched_boost" "15"
		write "/dev/stune/top-app/schedtune.sched_boost_no_override" "1"

		write "/dev/stune/schedtune.boost" "0"
		write "/dev/stune/schedtune.colocate" "0"
		write "/dev/stune/schedtune.prefer_idle" "0"
		write "/dev/stune/schedtune.sched_boost" "0"
		write "/dev/stune/schedtune.sched_boost_no_override" "0"
		
	elif [[ "$(getprop minazuki.mode)" == "Powersave" ]] || [[ "$(getprop minazuki.mode)" == "Sleeping" ]]; then
		
		write "/dev/stune/background/schedtune.boost" "0"
	    write "/dev/stune/background/schedtune.colocate" "0"
	    write "/dev/stune/background/schedtune.prefer_idle" "0"
	    write "/dev/stune/background/schedtune.sched_boost" "0"
	    write "/dev/stune/background/schedtune.sched_boost_no_override" "1"

	    write "/dev/stune/foreground/schedtune.boost" "0"
	    write "/dev/stune/foreground/schedtune.colocate" "0"
	    write "/dev/stune/foreground/schedtune.prefer_idle" "0"
	    write "/dev/stune/foreground/schedtune.sched_boost" "0"
	    write "/dev/stune/foreground/schedtune.sched_boost_no_override" "1"

	    write "/dev/stune/rt/schedtune.boost" "0"
		write "/dev/stune/rt/schedtune.colocate" "0"
		write "/dev/stune/rt/schedtune.prefer_idle" "0"
		write "/dev/stune/rt/schedtune.sched_boost" "0"
		write "/dev/stune/rt/schedtune.sched_boost_no_override" "1"

		write "/dev/stune/top-app/schedtune.boost" "1"
		write "/dev/stune/top-app/schedtune.colocate" "1"
		write "/dev/stune/top-app/schedtune.prefer_idle" "1"
		write "/dev/stune/top-app/schedtune.sched_boost" "0"
		write "/dev/stune/top-app/schedtune.sched_boost_no_override" "1"

		write "/dev/stune/schedtune.boost" "0"
		write "/dev/stune/schedtune.colocate" "0"
		write "/dev/stune/schedtune.prefer_idle" "0"
		write "/dev/stune/schedtune.sched_boost" "0"
		write "/dev/stune/schedtune.sched_boost_no_override" "0"
    fi
}

io_tune() {
    if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
    
        for scheduler in /sys/block/*/queue; do
			avail_scheds="$(cat "$scheduler/scheduler")"
			
			for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
				if [[ "$avail_scheds" == *"$sched"* ]]; then
					write "$scheduler/scheduler" "$sched"
					break
				fi
			done
				
            write "$scheduler/read_ahead_kb" "128"
            write "$scheduler/nr_requests" "64"
            write "$scheduler/iostats" "0"
            write "$scheduler/add_random" "0"
            write "$scheduler/nomerges" "0"
            write "$scheduler/rq_affinity" "1"
        done
        
        for iosched in /sys/block/*/iosched; do
            write "$iosched/slice_idle" "0"
            write "$iosched/group_idle" "1"
        done
        
        for zram in /sys/block/zram*/queue; do
			avail_scheds="$(cat "$zram/scheduler")"
			
			for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
				if [[ "$avail_scheds" == *"$sched"* ]]; then
					write "$zram/scheduler" "$sched"
					break
				fi
			done
			
			write "$zram/read_ahead_kb" "0"
		done
        
    elif [[ "$(getprop minazuki.mode)" == "Performance" ]] || [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
    
        for scheduler in /sys/block/*/queue; do
			avail_scheds="$(cat "$scheduler/scheduler")"
			
			for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
				if [[ "$avail_scheds" == *"$sched"* ]]; then
					write "$scheduler/scheduler" "$sched"
					break
				fi
			done

            write "$scheduler/read_ahead_kb" "256"
            write "$scheduler/nr_requests" "128"
            write "$scheduler/iostats" "0"
            write "$scheduler/add_random" "0"
            write "$scheduler/nomerges" "2"
            write "$scheduler/rq_affinity" "2"
        done
        
        for iosched in /sys/block/*/iosched; do
            write "$iosched/slice_idle" "0"
            write "$iosched/group_idle" "1"
        done
        
        for zram in /sys/block/zram*/queue; do
			avail_scheds="$(cat "$zram/scheduler")"
			
			for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
				if [[ "$avail_scheds" == *"$sched"* ]]; then
					write "$zram/scheduler" "$sched"
					break
				fi
			done
			
			write "$zram/read_ahead_kb" "0"
		done
        
    elif [[ "$(getprop minazuki.mode)" == "Powersave" ]] || [[ "$(getprop minazuki.mode)" == "Sleeping" ]]; then
    
        for scheduler in /sys/block/*/queue; do
			avail_scheds="$(cat "$scheduler/scheduler")"
			
			for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
				if [[ "$avail_scheds" == *"$sched"* ]]; then
					write "$scheduler/scheduler" "$sched"
					break
				fi
			done

            write "$scheduler/read_ahead_kb" "64"
            write "$scheduler/nr_requests" "512"
            write "$scheduler/iostats" "0"
            write "$scheduler/add_random" "0"
            write "$scheduler/nomerges" "0"
            write "$scheduler/rq_affinity" "1"
        done
        
        for iosched in /sys/block/*/iosched; do
            write "$iosched/slice_idle" "0"
            write "$iosched/group_idle" "1"
        done
        
        for zram in /sys/block/zram*/queue; do
			avail_scheds="$(cat "$zram/scheduler")"
			
			for sched in maple sio fiops bfq-sq bfq-mq bfq tripndroid zen anxiety mq-deadline deadline cfq noop none; do
				if [[ "$avail_scheds" == *"$sched"* ]]; then
					write "$zram/scheduler" "$sched"
					break
				fi
			done
			
			write "$zram/read_ahead_kb" "0"
		done
    fi
}

vm_tune() {
    if [[ "$(getprop minazuki.mode)" == "Balanced" ]]; then
        sync
		write "/proc/sys/vm/drop_caches" "2"
		write "/proc/sys/vm/dirty_background_ratio" "5"
		write "/proc/sys/vm/dirty_ratio" "30"
		write "/proc/sys/vm/dirty_expire_centisecs" "3000"
		write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
		write "/proc/sys/vm/page-cluster" "0"
		write "/proc/sys/vm/stat_interval" "10"
		write "/proc/sys/vm/overcommit_memory" "1"
		write "/proc/sys/vm/overcommit_ratio" "100"
		write "/proc/sys/vm/swappiness" "100"
		write "/proc/sys/vm/laptop_mode" "0"
		write "/proc/sys/vm/vfs_cache_pressure" "100"
        write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	    write "/proc/sys/vm/reap_mem_on_sigkill" "0"
		write "/proc/sys/vm/swap_ratio" "100"
		write "/proc/sys/vm/oom_dump_tasks" "0"
		write "/sys/module/lowmemorykiller/parameters/oom_reaper" "1"
		write "/sys/module/lowmemorykiller/parameters/lmk_fast_run" "0"
		write "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" "0"
		write "/proc/sys/vm/min_free_kbytes" "32768"
		
    elif [[ "$(getprop minazuki.mode)" == "Performance" ]] || [[ "$(getprop minazuki.mode)" == "Gaming" ]]; then
        sync
		write "/proc/sys/vm/drop_caches" "3"
		write "/proc/sys/vm/dirty_background_ratio" "2"
		write "/proc/sys/vm/dirty_ratio" "20"
		write "/proc/sys/vm/dirty_expire_centisecs" "3000"
		write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
		write "/proc/sys/vm/page-cluster" "0"
		write "/proc/sys/vm/stat_interval" "10"
		write "/proc/sys/vm/overcommit_memory" "1"
		write "/proc/sys/vm/overcommit_ratio" "100"
		write "/proc/sys/vm/swappiness" "60"
		write "/proc/sys/vm/laptop_mode" "0"
		write "/proc/sys/vm/vfs_cache_pressure" "200"
        write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	    write "/proc/sys/vm/reap_mem_on_sigkill" "0"
		write "/proc/sys/vm/swap_ratio" "100"
		write "/proc/sys/vm/oom_dump_tasks" "0"
		write "/sys/module/lowmemorykiller/parameters/oom_reaper" "1"
		write "/sys/module/lowmemorykiller/parameters/lmk_fast_run" "0"
		write "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" "0"
		write "/proc/sys/vm/min_free_kbytes" "32768"
		
	elif [[ "$(getprop minazuki.mode)" == "Powersave" ]] || [[ "$(getprop minazuki.mode)" == "Sleeping" ]]; then
	    sync
		write "/proc/sys/vm/drop_caches" "1"
		write "/proc/sys/vm/dirty_background_ratio" "15"
		write "/proc/sys/vm/dirty_ratio" "30"
		write "/proc/sys/vm/dirty_expire_centisecs" "500"
		write "/proc/sys/vm/dirty_writeback_centisecs" "3000"
		write "/proc/sys/vm/page-cluster" "0"
		write "/proc/sys/vm/stat_interval" "10"
		write "/proc/sys/vm/overcommit_memory" "1"
		write "/proc/sys/vm/overcommit_ratio" "100"
		write "/proc/sys/vm/swappiness" "60"
		write "/proc/sys/vm/laptop_mode" "0"
		write "/proc/sys/vm/vfs_cache_pressure" "50"
        write "/sys/module/process_reclaim/parameters/enable_process_reclaim" "0"
	    write "/proc/sys/vm/reap_mem_on_sigkill" "0"
		write "/proc/sys/vm/swap_ratio" "100"
		write "/proc/sys/vm/oom_dump_tasks" "0"
		write "/sys/module/lowmemorykiller/parameters/oom_reaper" "1"
		write "/sys/module/lowmemorykiller/parameters/lmk_fast_run" "0"
		write "/sys/module/lowmemorykiller/parameters/enable_adaptive_lmk" "0"
		write "/proc/sys/vm/min_free_kbytes" "32768"
    fi
}

apply_all_tune() {
    gpu_tune
    cpu_tune
    sched_tune
    schedboost_tune
    io_tune
    vm_tune
}