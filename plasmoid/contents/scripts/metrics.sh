#!/usr/bin/env bash
# ============================================================================
# System Metrics – Hardware-Agnostic JSON Output
# For use with the System Metrics Plasma 6 Plasmoid
#
# Supports: Intel / AMD / NVIDIA GPUs, all x86 CPUs, generic Linux
# Dependencies: bash, awk, coreutils
# Optional: lm_sensors (for CPU temp), nvidia-smi (for NVIDIA GPUs)
# ============================================================================

# --- CPU Usage ---
# Two-sample measurement from /proc/stat
read -ra cpu1 < <(grep '^cpu ' /proc/stat)
sleep 0.3
read -ra cpu2 < <(grep '^cpu ' /proc/stat)

idle1=${cpu1[4]}; idle2=${cpu2[4]}
total1=0; total2=0
for v in "${cpu1[@]:1}"; do ((total1 += v)); done
for v in "${cpu2[@]:1}"; do ((total2 += v)); done

diff_total=$((total2 - total1))
diff_idle=$((idle2 - idle1))
if ((diff_total > 0)); then
    cpu_use=$((100 * (diff_total - diff_idle) / diff_total))
else
    cpu_use=0
fi

# --- CPU Temperature (average of all cores) ---
cpu_temp=0
if command -v sensors &>/dev/null; then
    # Try Core X: entries first (Intel / some AMD)
    mapfile -t temps < <(sensors 2>/dev/null | grep -oP 'Core \d+:\s+\+\K[0-9]+')
    if ((${#temps[@]} > 0)); then
        sum=0
        for t in "${temps[@]}"; do ((sum += t)); done
        cpu_temp=$((sum / ${#temps[@]}))
    else
        # Fallback: try Tctl/Tdie (AMD Ryzen)
        amd_temp=$(sensors 2>/dev/null | grep -oP '(Tctl|Tdie):\s+\+\K[0-9]+' | head -n1)
        if [[ -n "$amd_temp" ]]; then
            cpu_temp=$amd_temp
        else
            # Last resort: grab any temperature
            cpu_temp=$(sensors 2>/dev/null | grep -oP '\+\K[0-9]+(?=\.[0-9]*°C)' | head -n1)
            cpu_temp=${cpu_temp:-0}
        fi
    fi
else
    # Fallback: sysfs thermal zones
    total=0; count=0
    for f in /sys/class/thermal/thermal_zone*/temp; do
        [[ -f "$f" ]] || continue
        val=$(<"$f")
        ((val > 0)) || continue
        ((total += val))
        ((count++))
    done
    ((count > 0)) && cpu_temp=$((total / count / 1000))
fi

# --- RAM ---
total_mem=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
avail_mem=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
if ((total_mem > 0)); then
    ram_used=$(( (total_mem - avail_mem) * 100 / total_mem ))
    ram_total_gb=$(awk "BEGIN {printf \"%.1f\", $total_mem / 1048576}")
    ram_used_gb=$(awk "BEGIN {printf \"%.1f\", ($total_mem - $avail_mem) / 1048576}")
else
    ram_used=0; ram_total_gb="0"; ram_used_gb="0"
fi

# --- SWAP ---
swap_total=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
swap_free=$(awk '/^SwapFree:/ {print $2}' /proc/meminfo)
if ((swap_total > 0)); then
    swap_used=$(( (swap_total - swap_free) * 100 / swap_total ))
else
    swap_used=0
fi

# --- ZRAM ---
zram_used=0
if [[ -f /sys/block/zram0/mm_stat ]]; then
    read -ra zram_stats < /sys/block/zram0/mm_stat
    zram_used_bytes=${zram_stats[0]}
    zram_max_bytes=$(</sys/block/zram0/disksize)
    ((zram_max_bytes > 0)) && zram_used=$((zram_used_bytes * 100 / zram_max_bytes))
fi

# --- DISK ---
read -r disk_used_pct disk_total disk_used_h < <(df -h / | awk 'NR==2 {gsub(/%/,"",$5); print $5, $2, $3}')

# --- Network (auto-detect active interface) ---
best_iface=""
best_diff=0
for i in /sys/class/net/*; do
    iface=$(basename "$i")
    [[ "$iface" == "lo" ]] && continue
    [[ -f "$i/statistics/rx_bytes" ]] || continue
    rx1=$(<"$i/statistics/rx_bytes")
    sleep 0.15
    rx2=$(<"$i/statistics/rx_bytes")
    diff=$((rx2 - rx1))
    if ((diff > best_diff)); then
        best_diff=$diff
        best_iface=$iface
    fi
done

# Fallback: first non-lo interface with carrier
if [[ -z "$best_iface" ]]; then
    for i in /sys/class/net/*; do
        iface=$(basename "$i")
        [[ "$iface" == "lo" ]] && continue
        if [[ -f "$i/carrier" ]] && [[ "$(<"$i/carrier" 2>/dev/null)" == "1" ]]; then
            best_iface=$iface
            break
        fi
    done
fi
iface=${best_iface:-"lo"}

# Measure throughput
rx1=$(<"/sys/class/net/$iface/statistics/rx_bytes")
tx1=$(<"/sys/class/net/$iface/statistics/tx_bytes")
sleep 0.5
rx2=$(<"/sys/class/net/$iface/statistics/rx_bytes")
tx2=$(<"/sys/class/net/$iface/statistics/tx_bytes")
rx_bps=$(( (rx2 - rx1) * 2 ))  # scale to per-second (0.5s sample)
tx_bps=$(( (tx2 - tx1) * 2 ))

format_rate() {
    local b=$1
    if ((b < 1024)); then
        printf "%d B/s" "$b"
    elif ((b < 1048576)); then
        awk "BEGIN {printf \"%.1f KB/s\", $b/1024}"
    else
        awk "BEGIN {printf \"%.2f MB/s\", $b/1048576}"
    fi
}
rx_human=$(format_rate "$rx_bps")
tx_human=$(format_rate "$tx_bps")

# --- GPU (auto-detect: Intel / AMD / NVIDIA) ---
gpu_use=0
gpu_type="none"

# Try Intel (RC6 residency – works on Gen6+ without special tools)
for card in /sys/class/drm/card*/; do
    if [[ -r "${card}power/rc6_residency_ms" ]]; then
        gpu_type="intel"
        r1=$(<"${card}power/rc6_residency_ms")
        sleep 0.15
        r2=$(<"${card}power/rc6_residency_ms")
        idle=$((r2 - r1))
        total=150  # ms
        ((idle < 0)) && idle=0
        ((idle > total)) && idle=$total
        gpu_use=$((100 - (idle * 100 / total)))
        break
    fi
done

# Try AMD (gpu_busy_percent – works on amdgpu driver)
if [[ "$gpu_type" == "none" ]]; then
    for card in /sys/class/drm/card*/device/; do
        if [[ -r "${card}gpu_busy_percent" ]]; then
            gpu_type="amd"
            gpu_use=$(<"${card}gpu_busy_percent")
            break
        fi
    done
fi

# Try NVIDIA (nvidia-smi)
if [[ "$gpu_type" == "none" ]] && command -v nvidia-smi &>/dev/null; then
    nv_use=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d ' ')
    if [[ -n "$nv_use" && "$nv_use" =~ ^[0-9]+$ ]]; then
        gpu_type="nvidia"
        gpu_use=$nv_use
    fi
fi

# --- Output as JSON ---
cat <<EOF
{
  "cpu": $cpu_use,
  "cpu_temp": $cpu_temp,
  "gpu": $gpu_use,
  "gpu_type": "$gpu_type",
  "ram": $ram_used,
  "ram_total_gb": "$ram_total_gb",
  "ram_used_gb": "$ram_used_gb",
  "swap": $swap_used,
  "zram": $zram_used,
  "disk": $disk_used_pct,
  "disk_total": "$disk_total",
  "disk_used": "$disk_used_h",
  "net_rx": "$rx_human",
  "net_tx": "$tx_human",
  "net_iface": "$iface",
  "net_rx_bytes": $rx_bps,
  "net_tx_bytes": $tx_bps
}
EOF
