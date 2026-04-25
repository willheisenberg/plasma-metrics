#!/usr/bin/env bash
# ============================================================================
# System Metrics – Hardware-Agnostic JSON Output
# For use with the System Metrics Plasma 6 Plasmoid
#
# Supports: Intel / AMD / NVIDIA GPUs, all x86 CPUs, generic Linux
# Dependencies: bash, awk, coreutils
# Optional: lm_sensors (for CPU temp), nvidia-smi (for NVIDIA GPUs)
# ============================================================================

export LC_ALL=C

STATE_DIR="/tmp/plasma-commandoutput-metrics"
STATE_FILE="$STATE_DIR/state"
mkdir -p "$STATE_DIR"

state_timestamp_ms=""
state_cpu_idle=""
state_cpu_total=""
state_iface=""
state_rx=""
state_tx=""
state_intel_card=""
state_intel_rc6=""

load_state() {
    [[ -r "$STATE_FILE" ]] || return 0

    while IFS='=' read -r key value; do
        case "$key" in
            timestamp_ms) state_timestamp_ms=$value ;;
            cpu_idle) state_cpu_idle=$value ;;
            cpu_total) state_cpu_total=$value ;;
            iface) state_iface=$value ;;
            rx) state_rx=$value ;;
            tx) state_tx=$value ;;
            intel_card) state_intel_card=$value ;;
            intel_rc6) state_intel_rc6=$value ;;
        esac
    done < "$STATE_FILE"
}

save_state() {
    cat > "$STATE_FILE" <<EOF
timestamp_ms=$now_ms
cpu_idle=$idle_now
cpu_total=$total_now
iface=$iface
rx=$rx_now
tx=$tx_now
intel_card=$intel_card_id
intel_rc6=$intel_rc6_now
EOF
}

clamp_percent() {
    local value=${1:-0}

    ((value < 0)) && value=0
    ((value > 100)) && value=100
    printf "%d" "$value"
}

format_rate() {
    local bytes_per_second=${1:-0}

    if ((bytes_per_second < 1024)); then
        printf "%d B/s" "$bytes_per_second"
    elif ((bytes_per_second < 1048576)); then
        awk "BEGIN {printf \"%.1f KB/s\", $bytes_per_second / 1024}"
    elif ((bytes_per_second < 1073741824)); then
        awk "BEGIN {printf \"%.2f MB/s\", $bytes_per_second / 1048576}"
    else
        awk "BEGIN {printf \"%.2f GB/s\", $bytes_per_second / 1073741824}"
    fi
}

read_first_temperature() {
    sed -nE 's/.*\+([0-9]+)(\.[0-9]+)?.*/\1/p' | head -n1
}

read_average_core_temperature() {
    local sum=0
    local count=0
    local temp=""

    while IFS= read -r temp; do
        [[ -n "$temp" ]] || continue
        ((sum += temp))
        ((count++))
    done

    if ((count > 0)); then
        printf "%d" "$((sum / count))"
    fi
}

find_cpu_temperature_from_sensors() {
    awk '
        BEGIN {
            best_score = -1
            best_temp = ""
            chip = ""
        }

        /^[[:space:]]*$/ {
            chip = ""
            next
        }

        chip == "" {
            chip = $0
            next
        }

        /^Adapter:/ {
            next
        }

        /^[^:]+:[[:space:]]+\+[0-9]+(\.[0-9]+)?/ {
            label = $0
            sub(/:.*/, "", label)

            temp = $0
            sub(/^[^:]+:[[:space:]]+\+/, "", temp)
            sub(/[^0-9.].*/, "", temp)
            temp = int(temp + 0)

            chip_l = tolower(chip)
            label_l = tolower(label)
            score = -1

            if (label ~ /^Package id [0-9]+$/ || label ~ /^Physical id [0-9]+$/) {
                score = 95
            } else if (label == "Tdie") {
                score = 94
            } else if (label == "Tctl") {
                score = 93
            } else if (label_l ~ /^cpu([ @:_-].*)?$/ || label_l == "peci agent 0") {
                score = 90
            } else if (chip_l ~ /(coretemp|k10temp|k8temp|zenpower|fam15h_power|cpu_thermal|x86_pkg_temp)/) {
                score = 80
            } else if ((chip_l ~ /(acpitz|cros_ec|thinkpad|asus_ec|it87|nct|f718|f753)/) && label_l ~ /^cpu/) {
                score = 70
            }

            if (score > best_score) {
                best_score = score
                best_temp = temp
            }
        }

        END {
            if (best_score >= 0) {
                print best_temp
            }
        }
    '
}

find_cpu_temperature_from_thermal_zones() {
    local path=""
    local temp_raw=""
    local temp_c=0
    local zone_type=""
    local zone_type_l=""
    local cpu_sum=0
    local cpu_count=0
    local fallback_max=0

    for path in /sys/class/thermal/thermal_zone*; do
        [[ -d "$path" && -r "$path/temp" ]] || continue

        temp_raw=$(<"$path/temp")
        [[ "$temp_raw" =~ ^[0-9]+$ ]] || continue
        ((temp_raw > 0)) || continue

        temp_c=$((temp_raw / 1000))
        ((temp_c > 0)) || continue

        if ((temp_c > fallback_max)); then
            fallback_max=$temp_c
        fi

        zone_type=$(<"$path/type" 2>/dev/null)
        zone_type_l=${zone_type,,}

        if [[ "$zone_type_l" =~ (x86_pkg_temp|cpu|pkg_temp|tcpu|cpu_thermal|soc_thermal|coretemp|k10temp) ]]; then
            ((cpu_sum += temp_c))
            ((cpu_count++))
        fi
    done

    if ((cpu_count > 0)); then
        printf "%d" "$((cpu_sum / cpu_count))"
    elif ((fallback_max > 0)); then
        printf "%d" "$fallback_max"
    fi
}

is_physical_interface() {
    local path=$1
    [[ -e "$path/device" || -d "$path/wireless" ]]
}

choose_network_interface() {
    local candidate=""
    local path=""
    local iface_name=""
    local state=""

    candidate=$(awk '$2 == "00000000" { print $1; exit }' /proc/net/route 2>/dev/null)
    if [[ -n "$candidate" && -d "/sys/class/net/$candidate" && "$candidate" != "lo" ]]; then
        printf "%s" "$candidate"
        return 0
    fi

    if [[ -n "$state_iface" && -d "/sys/class/net/$state_iface" && "$state_iface" != "lo" ]] \
        && is_physical_interface "/sys/class/net/$state_iface"; then
        printf "%s" "$state_iface"
        return 0
    fi

    for path in /sys/class/net/*; do
        [[ -d "$path" ]] || continue
        iface_name=$(basename "$path")
        [[ "$iface_name" == "lo" ]] && continue
        state=$(cat "$path/operstate" 2>/dev/null)
        if is_physical_interface "$path" && [[ "$state" == "up" || "$state" == "unknown" ]]; then
            printf "%s" "$iface_name"
            return 0
        fi
    done

    for path in /sys/class/net/*; do
        [[ -d "$path" ]] || continue
        iface_name=$(basename "$path")
        [[ "$iface_name" == "lo" ]] && continue
        state=$(cat "$path/operstate" 2>/dev/null)
        if [[ "$state" == "up" || "$state" == "unknown" ]]; then
            printf "%s" "$iface_name"
            return 0
        fi
    done

    for path in /sys/class/net/*; do
        [[ -d "$path" ]] || continue
        iface_name=$(basename "$path")
        [[ "$iface_name" == "lo" ]] && continue
        printf "%s" "$iface_name"
        return 0
    done

    printf "lo"
}

load_state

now_ms=$(date +%s%3N 2>/dev/null)
if [[ ! "$now_ms" =~ ^[0-9]+$ ]]; then
    now_ms=$(( $(date +%s) * 1000 ))
fi

delta_ms=0
if [[ "$state_timestamp_ms" =~ ^[0-9]+$ ]] && ((now_ms > state_timestamp_ms)); then
    delta_ms=$((now_ms - state_timestamp_ms))
fi

# --- CPU Usage ---
read -ra cpu_now < <(grep '^cpu ' /proc/stat)
idle_now=${cpu_now[4]}
total_now=0
for value in "${cpu_now[@]:1}"; do
    ((total_now += value))
done

cpu_use=0
if [[ "$state_cpu_idle" =~ ^[0-9]+$ && "$state_cpu_total" =~ ^[0-9]+$ ]]; then
    cpu_total_diff=$((total_now - state_cpu_total))
    cpu_idle_diff=$((idle_now - state_cpu_idle))
    if ((cpu_total_diff > 0)); then
        cpu_use=$((100 * (cpu_total_diff - cpu_idle_diff) / cpu_total_diff))
    fi
fi
cpu_use=$(clamp_percent "$cpu_use")

# --- CPU Temperature ---
cpu_temp=0
if command -v sensors >/dev/null 2>&1; then
    sensors_output=$(sensors 2>/dev/null)
    avg_core_temp=$(printf "%s\n" "$sensors_output" | sed -nE 's/^Core [0-9]+: +\+([0-9]+)(\.[0-9]+)?.*/\1/p' | read_average_core_temperature)
    if [[ -n "$avg_core_temp" ]]; then
        cpu_temp=$avg_core_temp
    else
        best_sensor_temp=$(printf "%s\n" "$sensors_output" | find_cpu_temperature_from_sensors)
        if [[ -n "$best_sensor_temp" ]]; then
            cpu_temp=$best_sensor_temp
        else
            fallback_temp=$(find_cpu_temperature_from_thermal_zones)
            if [[ -n "$fallback_temp" ]]; then
                cpu_temp=$fallback_temp
            else
                fallback_temp=$(printf "%s\n" "$sensors_output" | read_first_temperature)
                cpu_temp=${fallback_temp:-0}
            fi
        fi
    fi
else
    fallback_temp=$(find_cpu_temperature_from_thermal_zones)
    cpu_temp=${fallback_temp:-0}
fi

# --- RAM ---
total_mem=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
avail_mem=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)
if ((total_mem > 0)); then
    ram_used=$(((total_mem - avail_mem) * 100 / total_mem))
    ram_total_gb=$(awk "BEGIN {printf \"%.1f\", $total_mem / 1048576}")
    ram_used_gb=$(awk "BEGIN {printf \"%.1f\", ($total_mem - $avail_mem) / 1048576}")
else
    ram_used=0
    ram_total_gb="0"
    ram_used_gb="0"
fi

# --- SWAP ---
swap_total=$(awk '/^SwapTotal:/ { print $2 }' /proc/meminfo)
swap_free=$(awk '/^SwapFree:/ { print $2 }' /proc/meminfo)
has_swap=false
if ((swap_total > 0)); then
    swap_used=$(((swap_total - swap_free) * 100 / swap_total))
    has_swap=true
else
    swap_used=0
fi

# --- ZRAM ---
zram_used=0
has_zram=false
zram_total_used_bytes=0
zram_total_bytes=0
for path in /sys/block/zram*; do
    [[ -r "$path/mm_stat" && -r "$path/disksize" ]] || continue

    read -ra zram_stats < "$path/mm_stat"
    zram_used_bytes=${zram_stats[0]:-0}
    zram_max_bytes=$(<"$path/disksize")

    if [[ "$zram_used_bytes" =~ ^[0-9]+$ && "$zram_max_bytes" =~ ^[0-9]+$ ]] && ((zram_max_bytes > 0)); then
        ((zram_total_used_bytes += zram_used_bytes))
        ((zram_total_bytes += zram_max_bytes))
    fi
done

if ((zram_total_bytes > 0)); then
    zram_used=$((zram_total_used_bytes * 100 / zram_total_bytes))
    has_zram=true
fi

# --- DISK ---
read -r disk_used_pct disk_total disk_used_h < <(df -h / | awk 'NR == 2 { gsub(/%/, "", $5); print $5, $2, $3 }')
disk_used_pct=${disk_used_pct:-0}
disk_total=${disk_total:-0}
disk_used_h=${disk_used_h:-0}

# --- Network ---
iface=$(choose_network_interface)
rx_now=0
tx_now=0
rx_bps=0
tx_bps=0

if [[ -r "/sys/class/net/$iface/statistics/rx_bytes" && -r "/sys/class/net/$iface/statistics/tx_bytes" ]]; then
    rx_now=$(<"/sys/class/net/$iface/statistics/rx_bytes")
    tx_now=$(<"/sys/class/net/$iface/statistics/tx_bytes")

    if [[ "$state_iface" == "$iface" && "$state_rx" =~ ^[0-9]+$ && "$state_tx" =~ ^[0-9]+$ ]] && ((delta_ms > 0)); then
        rx_diff=$((rx_now - state_rx))
        tx_diff=$((tx_now - state_tx))
        ((rx_diff < 0)) && rx_diff=0
        ((tx_diff < 0)) && tx_diff=0
        rx_bps=$((rx_diff * 1000 / delta_ms))
        tx_bps=$((tx_diff * 1000 / delta_ms))
    fi
fi

rx_human=$(format_rate "$rx_bps")
tx_human=$(format_rate "$tx_bps")

# --- GPU (auto-detect: Intel / AMD / NVIDIA) ---
gpu_use=0
gpu_type="none"
intel_card_id=""
intel_rc6_now=""

for card in /sys/class/drm/card*; do
    [[ -d "$card" ]] || continue
    if [[ -r "$card/power/rc6_residency_ms" ]]; then
        gpu_type="intel"
        intel_card_id=$(basename "$card")
        intel_rc6_now=$(<"$card/power/rc6_residency_ms")
        if [[ "$state_intel_card" == "$intel_card_id" && "$state_intel_rc6" =~ ^[0-9]+$ ]] && ((delta_ms > 0)); then
            rc6_idle_ms=$((intel_rc6_now - state_intel_rc6))
            ((rc6_idle_ms < 0)) && rc6_idle_ms=0
            if ((rc6_idle_ms > delta_ms)); then
                rc6_idle_ms=$delta_ms
            fi
            gpu_use=$((100 - (rc6_idle_ms * 100 / delta_ms)))
        fi
        break
    fi
done

if [[ "$gpu_type" == "none" ]]; then
    for card in /sys/class/drm/card*/device; do
        [[ -d "$card" ]] || continue
        if [[ -r "$card/gpu_busy_percent" ]]; then
            gpu_type="amd"
            gpu_use=$(<"$card/gpu_busy_percent")
            break
        fi
    done
fi

if [[ "$gpu_type" == "none" ]] && command -v nvidia-smi >/dev/null 2>&1; then
    nv_use=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d ' ')
    if [[ "$nv_use" =~ ^[0-9]+$ ]]; then
        gpu_type="nvidia"
        gpu_use=$nv_use
    fi
fi

gpu_use=$(clamp_percent "$gpu_use")

save_state

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
  "has_swap": $has_swap,
  "swap": $swap_used,
  "has_zram": $has_zram,
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
