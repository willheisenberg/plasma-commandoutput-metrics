##Install:
##widget: command output
##sudo pacman -S ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono
##sudo pacman -S intel-gpu-tools jq
##sudo pacman -S perf
##sudo setcap cap_perfmon+ep /usr/bin/perf 
#!/usr/bin/env bash

# --- CPU ---
cpu1=($(grep '^cpu ' /proc/stat)); sleep 0.5; cpu2=($(grep '^cpu ' /proc/stat))
idle1=${cpu1[4]}; idle2=${cpu2[4]}
total1=0; total2=0
for v in "${cpu1[@]:1}"; do total1=$((total1 + v)); done
for v in "${cpu2[@]:1}"; do total2=$((total2 + v)); done
cpu_use=$((100 * ( (total2 - total1) - (idle2 - idle1) ) / (total2 - total1) ))

# --- CPU Temp (Durchschnitt aller Kerne) ---
if command -v sensors &>/dev/null; then
  temps=($(sensors | grep -E 'Core [0-9]+:' | awk '{gsub(/\+|°C/,"",$3); print int($3)}'))
  if (( ${#temps[@]} > 0 )); then
    sum=0
    for t in "${temps[@]}"; do ((sum+=t)); done
    cpu_temp=$((sum / ${#temps[@]}))
  else
    cpu_temp=$(sensors | grep -Eo '[0-9]+(\.[0-9]+)?°C' | awk '{gsub(/°C/,""); print int($1)}' | head -n1)
  fi
else
  # Fallback über sysfs
  files=(/sys/class/thermal/thermal_zone*/temp)
  total=0; count=0
  for f in "${files[@]}"; do
    [[ -f $f ]] || continue
    val=$(cat "$f")
    ((val>0)) || continue
    total=$((total + val))
    ((count++))
  done
  cpu_temp=$((count>0 ? total / count / 1000 : 0))
fi

# --- RAM ---
total_mem=$(grep MemTotal /proc/meminfo | awk '{print $2}')
avail_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
ram_used=$(( ( (total_mem - avail_mem) * 100 ) / total_mem ))

# --- SWAP ---
swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
swap_free=$(grep SwapFree /proc/meminfo | awk '{print $2}')
swap_used=$(( swap_total>0 ? ( ( (swap_total - swap_free) * 100 ) / swap_total ) : 0 ))

# --- ZRAM ---
if [[ -d /sys/block/zram0 ]]; then
    zram_stats=($(cat /sys/block/zram0/mm_stat))
    zram_used_bytes=${zram_stats[0]}
    zram_max_bytes=$(cat /sys/block/zram0/disksize)
    zram_used=$(( zram_max_bytes>0 ? (zram_used_bytes * 100 / zram_max_bytes) : 0 ))
else
    zram_used=0
fi

# --- DISK ---
disk=$(df -h / | awk 'NR==2 {print $5}')

# --- Detect active network interface ---
best_iface=""
best_diff=0
for i in /sys/class/net/*; do
  iface=$(basename "$i")
  [[ -f "$i/statistics/rx_bytes" ]] || continue
  rx1=$(< "$i/statistics/rx_bytes")
  sleep 0.2
  rx2=$(< "$i/statistics/rx_bytes")
  diff=$((rx2 - rx1))
  if (( diff > best_diff )); then
    best_diff=$diff
    best_iface=$iface
  fi
done
iface=${best_iface:-"wlan0"}

# --- Network traffic (dynamic units) ---
rx1=$(< /sys/class/net/$iface/statistics/rx_bytes)
tx1=$(< /sys/class/net/$iface/statistics/tx_bytes)
sleep 1
rx2=$(< /sys/class/net/$iface/statistics/rx_bytes)
tx2=$(< /sys/class/net/$iface/statistics/tx_bytes)
rx_diff=$((rx2 - rx1))
tx_diff=$((tx2 - tx1))

format_rate() {
  local b=$1
  if (( b < 1024 )); then
    printf "%d B/s" "$b"
  elif (( b < 1048576 )); then
    awk "BEGIN {printf \"%.1f KB/s\", $b/1024}"
  else
    awk "BEGIN {printf \"%.2f MB/s\", $b/1048576}"
  fi
}
rx_human=$(format_rate "$rx_diff")
tx_human=$(format_rate "$tx_diff")

# --- GPU (Intel Skylake Gen9 via RC6 residency, kernel-native) ---
gpu_use=0
if [[ -r /sys/class/drm/card1/power/rc6_residency_ms ]]; then
    r1=$(< /sys/class/drm/card1/power/rc6_residency_ms)
    sleep 0.25
    r2=$(< /sys/class/drm/card1/power/rc6_residency_ms)

    idle=$((r2 - r1))
    total=250   # ms

    ((idle<0)) && idle=0
    ((idle>total)) && idle=total

    gpu_use=$((100 - (idle * 100 / total)))
fi



# --- Output (Nerd Font icons) ---
printf "%s %2d%%   %s %2d%%   %s %2d°C   %s %2d%%   %s %2d%%   %s %2d%%   %s %s  ↓%s ↑%s\n" \
  "󰍛" "$cpu_use" "󰢮" "$gpu_use"  "" "$cpu_temp" "󰘚" "$ram_used" "" "$zram_used" "󰟜" "$swap_used" "󰋊" "$disk" "$rx_human" "$tx_human"
